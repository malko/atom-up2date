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
        , '</dl><div class="actions"><a class="cancel">cancel</a> <a href="https://github.com/atom/atom/releases">go to download page</a></div>'
    ].join('')

    message.classList.add('message')
    @element.appendChild(message)
    addActionListener = (button) -> button.addEventListener('click', () -> self.toggle())
    [].slice.call(@element.querySelectorAll('.actions a')).forEach(addActionListener)

  setLatestRelease: (release) ->
    @element.querySelector('#up2date_latest_tag').innerHTML = release.tag_name
    @element.querySelector('#up2date_latest_desc').innerHTML = release.body.replace(/\n/g, '<br />')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
      visible: !!@element.parentElement

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  # Toggle the visibility of this view
  toggle: ->
    if @element.parentElement?
      @element.remove()
    else
      atom.workspace.addTopPanel({item:@element})
