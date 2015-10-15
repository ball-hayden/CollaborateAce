#= require ace/ace
#= require collaborate

describe 'Adapters.TextAreaAdapter', ->
  Range = ace.require('ace/range').Range

  beforeEach =>
    fixture.set('<div id="editor"></div>')

    @cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(@cable, 'DocumentChannel', 'body')
    @collaborativeAttribute = @collaborate.addAttribute('body')

    @editor = ace.edit('editor')
    @session = @editor.getSession()
    @document = @session.getDocument()

    @adapter = new Collaborate.Adapters.AceAdapter(@collaborativeAttribute, @editor)

  it 'should respond to text changes', =>
    spyOn(@collaborativeAttribute, 'localOperation')

    position = @document.indexToPosition(0)
    @document.insert(position, 'Test')

    expect(@collaborativeAttribute.localOperation).toHaveBeenCalled()

  describe 'generating an OT operation from a text change', =>
    beforeEach =>
      spyOn(@collaborativeAttribute, 'localOperation')

    it 'should be able to insert new text', =>
      position = @document.indexToPosition(0)
      @document.insert(position, 'Test')

      expectedOperation = (new ot.TextOperation()).insert('Test')

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle insert operations at the beginning of the existing text', =>
      @document.setValue('ing')

      position = @document.indexToPosition(0)
      @document.insert(position, 'Test')

      expectedOperation = (new ot.TextOperation()).insert('Test').retain(3)

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle insert operations in the middle of the existing text', =>
      @document.setValue('test123')

      position = @document.indexToPosition(4)
      @document.insert(position, 'ing')

      expectedOperation = (new ot.TextOperation()).retain(4).insert('ing').retain(3)

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle insert operations at the end of the existing text', =>
      @document.setValue('test')

      position = @document.indexToPosition(4)
      @document.insert(position, 'ing\n\n123')

      expectedOperation = (new ot.TextOperation()).retain(4).insert('ing\n\n123')

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle delete operations at the start', =>
      @document.setValue('test123')

      deleteRange = new Range(0, 0, 0, 4)

      @document.remove(deleteRange)

      expectedOperation = (new ot.TextOperation()).delete(4).retain(3)
      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle delete operations in the middle', =>
      @document.setValue('testing123')

      deleteRange = new Range(0, 4, 0, 7)

      @document.remove(deleteRange)

      expectedOperation = (new ot.TextOperation()).retain(4).delete(3).retain(3)

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to handle delete operations at the end', =>
      @document.setValue('testing')

      deleteRange = new Range(0, 4, 0, 7)

      @document.remove(deleteRange)

      expectedOperation = (new ot.TextOperation()).retain(4).delete(3)

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

    it 'should be able to delete all text', =>
      @document.setValue('testing')

      deleteRange = new Range(0, 0, 0, 7)

      @document.remove(deleteRange)

      expectedOperation = (new ot.TextOperation()).delete(7)

      expect(@collaborativeAttribute.localOperation).toHaveBeenCalledWith(expectedOperation)

  describe 'applying remote changes', =>
    beforeEach =>
      @document.setValue('test')

      spyOn(@collaborativeAttribute, 'localOperation')

      operation = (new ot.TextOperation()).retain(4).insert('ing')

      @adapter.applyRemoteOperation(operation)

    it 'should update the content of the textArea', =>
      expect(@document.getValue()).toEqual('testing')

    it 'should not call localOperation', =>
      expect(@collaborativeAttribute.localOperation).not.toHaveBeenCalled()
