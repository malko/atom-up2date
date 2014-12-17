Up2dateView = require './up2date-view'
semver = require 'semver'
releasesCache =
getLatestRelease = (releaseList) ->
    releaseList.sort(semver.rcompare)[0]

module.exports =
  up2dateView: null

  activate: (state) ->
    view = @up2dateView = new Up2dateView(state.up2dateViewState)
    new Promise(
        (resolve, reject) ->
            xhr = new XMLHttpRequest();
            xhr.open('GET', 'https://api.github.com/repos/atom/atom/releases', true);
            xhr.onload = () -> resolve(releasesCache = JSON.parse(xhr.response))
            xhr.onerror = reject
            xhr.send()
    )
    .then( getLatestRelease )
    .then((release) -> view.setLatestRelease(release) )
    .then(() ->
        if releasesCache[0].tag_name > 'v' + atom.getLoadSettings().appVersion
            view.toggle();
    )

  deactivate: ->
    @up2dateView.destroy()

  serialize: ->
    up2dateViewState: @up2dateView.serialize()
