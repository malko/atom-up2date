module.exports =
class Up2dateView
  constructor: (serializeState) ->
    self = this
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('up2date',  'overlay', 'from-top')

    # Create message element
    message = document.createElement('div')
    message.innerHTML = [
        '<h1>New Atom release available</h1>'
        , '<dl><dt>current atom version: v' + atom.getLoadSettings().appVersion + '</dt>'
        , '<dt>latest atom version: <span id="up2date_latest_tag">...</span></dt>'
        , '<dd id="up2date_latest_desc"></dd>'
        , '</dl><div class="actions"><a class="cancel">cancel</a> <a href="https://github.com/atom/atom/releases" class="ok" id="up2date_release_link">go to download page</a></div>'
    ].join('')

    message.classList.add('message')
    @element.appendChild(message)

    @element.querySelector('.actions .cancel').addEventListener('click', () -> self.toggle());
    @element.querySelector('.actions .ok').addEventListener('click', () -> self.asyncToggle());

  setLatestRelease: (release) ->
    @element.querySelector('#up2date_latest_tag').innerHTML = release.tag_name
    @element.querySelector('#up2date_latest_desc').innerHTML = release.body.replace(/\n/g, '<br />')
    @element.querySelector('#up2date_release_link').href = 'https://github.com/atom/atom/releases/tag/' + release.tag_name

  # Returns an object that can be retrieved when package is activated
  serialize: ->
      visible: !!@element.parentElement

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  asyncToggle: ->
     setTimeout(this.toggle.bind(this), 10)

  # Toggle the visibility of this view
  toggle: ->
    if @element.parentElement?
      @element.remove()
    else
      atom.workspace.addTopPanel({item:@element})
