Up2dateView = require './up2date-view'
semver = require 'semver'

ignoreBeta = true
isNotIgnored = (release) -> if ignoreBeta && release.prerelease then false else true

getLatestRelease = (releaseList) ->
  releaseList.filter(isNotIgnored).sort((a,b) ->
    semver.rcompare(a.tag_name, b.tag_name)
  )[0]

module.exports =
  config:
    ignoreBeta:
      title: 'Ignore beta release'
      type: 'boolean'
      default: true
    dayPeriod:
      title: 'How many days between checks (0 to check on every atom start)'
      type: 'integer'
      default: 0

  up2dateView: null

  activate: (state) ->
    view = @up2dateView = new Up2dateView(state.up2dateViewState)
    ignoreBeta = atom.config.get('up2date.ignoreBeta');
    dayPeriod = atom.config.get('up2date.dayPeriod');
    lastCheckDate = +(localStorage.getItem('up2date.lastCheckDate') || 0)
    if lastCheckDate && (lastCheckDate + dayPeriod * 86400000) > Date.now()
      return
    lastCheckDate = new Date(new Date().toISOString().split('T')[0])
    localStorage.setItem('up2date.lastCheckDate', lastCheckDate.getTime())
    new Promise(
        (resolve, reject) ->
            xhr = new XMLHttpRequest();
            xhr.open('GET', 'https://api.github.com/repos/atom/atom/releases', true);
            xhr.onload = () -> resolve(releasesCache = JSON.parse(xhr.response))
            xhr.onerror = reject
            xhr.send()
    )
    .then( getLatestRelease )
    .then((release) ->
      view.setLatestRelease(release)
      release
    )
    .then((release) ->
        if release.tag_name > 'v' + atom.getLoadSettings().appVersion
          view.toggle();
    )

  deactivate: ->
    @up2dateView.destroy()

  serialize: ->
    up2dateViewState: @up2dateView.serialize()
