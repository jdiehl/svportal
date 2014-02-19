/**
 * class AONotice
 * create a notice
 * parameters:
 *   element   -> reference element
 *   content   -> the content
 *   className -> the css class name to use
 */
AONotice = Class.create();

// close a notice from the inside
AONotice.close = function(element) {
	$(element).up('div').close();
};

AONotice.prototype = {

// constructor: render
initialize: function(element, content, className) {
	this.element = $(element);
	this.content = content;
	this.className = className;
	this.render();
},

// render the notice
render: function() {
	this.div = $(document.createElement('DIV'));
	this.div.addClassName('float');
	this.div.addClassName(this.className);
	this.div.update(this.content);
	this.div.close = this.close.bind(this);
	this.element.appendChild(this.div);
	this.element._onclick = this.element.onclick;
	this.element.onclick = '';
},

// close and remove the notice
close: function() {
	this.div.remove();
	this.element.onclick = this.element._onclick;
}
}

/**
 * class AOError < AONotice
 * create an error message
 * parameters:
 *   element   -> reference element
 *   content   -> the content
 */
AOError = Class.create();
AOError.prototype = Object.clone(AONotice.prototype);
AOError.prototype.render = function() {
	this.div = $(document.createElement('DIV'));
	this.div.addClassName('float');
	this.div.addClassName('error');
	this.div.update(this.content);
	this.div.onclick = function() { this.close(); }.bind(this);
	this.element.appendChild(this.div);
	this.element.observe('onclick', function() { this.close(); }.bindAsEventListener(this));
}


/**
 * class AOInput
 * renders edit form to change a specific text attribute
 * parameters:
 *   element -> place in document to render in
 *   id      -> id of the element
				(no model name required here; the id is sufficient!
				The update is performed by raising an Ajax POST request,
				RESTFul::ActiveRecordController then automatically updates the
				specific active record)
 *   key     -> attribute name
 *   value   -> attribute value
 */
AOInput = Class.create();
AOInput.prototype = {

// constructor
initialize: function(element, obj_class, obj_id, key, value) {
	this.element = element;
	this.obj_class = obj_class;
	this.id = obj_id;
	this.key = key;
	this.value = value == null ? this.element.innerHTML : value;
	this.render();
},

// render the form
render: function() {
	// events
	this.element.onclick = '';
	window.onunload = this.onSubmit.bind(this);
	window.onkeypress = this.onKeyPress.bind(this);

	// define the input
	this.input = document.createElement('INPUT');
	this.input.value = this.value;
	this.input.onblur = this.onSubmit.bind(this);
	
	// define the form and add input
	form = document.createElement('FORM');
	form.appendChild(this.input);
	form.onsubmit = function() { this.onNext(); return false; }.bind(this);
	
	// add form to the element
	this.element.innerHTML = '';
	this.element.appendChild(form);
	
	// select and focus input (this fires onblur of existing forms)
	this.input.focus();
	this.input.select();
},

// remove the form
remove: function() {
	this.loading(false);
	this.update(this.value == '' ? '&nbsp;' : this.value);
	this.element.onclick = function() { this.render(); }.bind(this);
},

// update the cell value
update: function(content) {
	this.element.innerHTML = content;
},

// the cell is loading something
loading: function(onOff) {
	if(onOff) { this.element.addClassName('load'); }
	else { this.element.removeClassName('load'); }
},


// keypress handler
onKeyPress: function(e) {
	if(window.event) {
		key = event.keyCode;
		Esc = 27;
		Tab = 9;
		shift = event.shiftKey;
	} else {
		key = e.keyCode;
		Esc = e.DOM_VK_ESCAPE;
		Tab = e.DOM_VK_TAB;
		shift = e.shiftKey;
	}
	if(key == Esc) { return this.onCancel(); }
	if(key == Tab) { return shift ? this.onPrev() : this.onNext(); }
},

// submit form
onSubmit: function() {
	if(this.input.value == this.value) { return this.remove(); }
	this.update(this.input.value);
	this.loading(true);
	var options = {
		asynchronous:true,
		evalScripts:true,
		method:'post',
		onSuccess:this.onSuccess.bind(this),
		onComplete: this.onComplete.bind(this),
		onFailure:this.onFailure.bind(this),
		parameters:{'id': this.id}
	};
	// set key specific parameter
	eval('options.parameters["user['+ this.key +']"] = "'+ this.input.value +'";');
	new Ajax.Request(document.URL, options);
},

// cancel form
onCancel: function() {
	this.remove();
},

// request complete
onComplete: function() {
	this.loading(false);
},

// storing was successful
onSuccess: function(t) {
	this.value = this.input.value;
	this.remove();
},

// storing failes
onFailure: function(t) {
	this.remove();
	new AOError(this.element, t.responseText, 'error');
},

// save and select the next item from the table
onNext: function() {
	this.onSubmit();
	elements = $$('.ao');
	for(i=0;i<elements.length;i++) { if(elements[i] == this.element) break; }
	if(++i >= elements.length) { i = 0; }
	elements[i].onclick();
},

// save and select the previous item from the table
onPrev: function() {
	this.onSubmit();
	elements = $$('.ao');
	for(i=0;i<elements.length;i++) { if(elements[i] == this.element) break; }
	if(--i < 0) { i = elements.length; }
	elements[i].onclick();
}

};


/**
 * class AOSelect < AOInput
 * renders a selectBox.. options are retrieved via AJAX call and cached
 */
AOSelect = Class.create();
AOSelect.prototype = Object.clone(AOInput.prototype);
AOSelect.cache = {};

// renders a selectBox (options are retrieved by an AJAX call and cached)
AOSelect.prototype.render = function(options) {
	// events
	this.element.onclick = '';
	window.onunload = this.onSubmit.bind(this);
	window.onkeypress = this.onKeyPress.bind(this);

	// retrieve the options from cache or fetch them
	if(options) {
		AOSelect.cache[this.key] = options;
	} else {
		options = AOSelect.cache[this.key];
	}
	if(!options) { return this.getOptions(); }
	
	// define the input
	this.input = document.createElement('SELECT');
	this.input.innerHTML = options;
	for(i=0; i<this.input.options.length; i++) {
		if(this.input.options[i].value == this.value) { this.input.options[i].selected = true; };
	}
	this.input.onchange = this.onSubmit.bind(this);
	this.input.onblur = this.onCancel.bind(this);

	// add form to the element
	this.element.innerHTML = '';
	this.element.appendChild(this.input);
	
	// select and focus input (this fires onblur of existing forms)
	this.input.focus();
};

// fire ajax query for the select options
AOSelect.prototype.getOptions = function() {
	this.loading(true);
	new Ajax.Request(document.URL, {
		method: 'OPTIONS',
		onSuccess: this.onOptionsSuccess.bind(this),
		onFailure: this.onFailure.bind(this),
		parameters: {k:this.key}
	});
};

// render the response
AOSelect.prototype.onOptionsSuccess = function(t) {
	this.loading(false);
	this.render(t.responseText);
};

// remove the form
AOSelect.prototype.update = function(content) {
	for(i=0; i<this.input.options.length; i++) {
		if(this.input.options[i].value == content) { var text = this.input.options[i].innerHTML; };
	}
	this.element.innerHTML = text;
};