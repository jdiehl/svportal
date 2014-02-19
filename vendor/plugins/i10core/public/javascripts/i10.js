// base classes
I10 = {};
I10.Common = {};
I10.Request = {};

// query string method that supports nested records
I10.Common.toQueryString = function(object, prefix) {
	return $H(object).map(function(p) {
		var key = encodeURIComponent(prefix ? prefix+'['+p.key+']' : p.key);
		var value = p.value;
	    if(Object.isUndefined(value)) { return key; }
		if(typeof(value) == 'object') { return I10.Common.toQueryString(value, key); }
	    return key + '=' + encodeURIComponent(String.interpret(value));
	}).join('&');
};

// merge options hashes
I10.Common.mergeOptions = function(defaults, overrides) {
	options = defaults || {};
	Object.extend(options, overrides || {});
	return options;
};

// humanize string
I10.Common.humanize = function(string) {
	string = string.gsub(/_id$/, '').gsub('_', ' ');
	return string.charAt(0).toUpperCase() + string.substr(1).toLowerCase();
};

// simple request
I10.Request.Base = Class.create({
	RUN_ON_INIT: true,
	// constructor
	initialize: function(element, url, options) {
		I10.lastRequest = this;
		this.element = $(element);
		this.url = url ? url : document.location;
		this.options = I10.Common.mergeOptions({
			evalScripts:true,
			onLoading:this.onLoading.bind(this),
			onSuccess:this.onSuccess.bind(this),
			onFailure:this.onFailure.bind(this),
			onComplete:this.onComplete.bind(this)
	    }, options);
		if(this.RUN_ON_INIT) { this.go(); }
	},
	// go
	go: function() {
		this.performRequest();
		this.showLoading();
	},
	// perform the actual request
	performRequest: function() {
		this.request = new Ajax.Request(this.url, this.options);
	},
	// show loading indicator
	showLoading: function() {
		if(this.element) { this.element.addClassName('loading'); }
	},
	// hide loading indicator
	hideLoading: function() {
		if(this.element) { this.element.removeClassName('loading'); }
	},
	// hooks
	onLoading:function() {
		this.showLoading();
	},
	onComplete:function(response) {
		this.hideLoading();
	},
	beforeRequest:function(response) {},
	afterRequest:function(response) {},
	onSuccess:function(response) {},
	onFailure:function(response) {}
});

// update request
I10.Request.Update = Class.create(I10.Request.Base, {
	initialize:function($super, element, target, url, options) {
		this.target = $(target);
		options = I10.Common.mergeOptions({method:'get'}, options);
		$super(element, url, options);
	},
	performRequest: function($super) {
		if(!this.target) { return $super(); }
		this.request = new Ajax.Updater({success:this.target}, this.url, this.options);
	},
	onSuccess:function(response) {
		this.target.show();
	}
});

// request that will refresh the page on success
I10.Request.Redirect = Class.create(I10.Request.Base, {
	initialize:function($super, element, url, redirectUrl, options) {
		this.redirectUrl = redirectUrl;
		$super(element, url, options);
	},
	onSuccess:function(response) {
		if(this.redirectUrl) {
			window.location = this.redirectUrl;
		} else {
			window.location.reload();
		}
	}
});

// update record request
I10.Request.UpdateRecord = Class.create(I10.Request.Update, {
	initialize:function($super, element, target, url, record, options) {
		this.record = record;
		options = I10.Common.mergeOptions({method:'post'}, options);
		if(this.record) { options.parameters = I10.Common.toQueryString(this.record); }
		$super(element, target, url, options);
	}
});

// general active record deleter 
I10.Request.DeleteRecord = Class.create(I10.Request.UpdateRecord, {
	initialize:function($super, element, target, url, record, options) {
		if(!options) { options = {}; }
		options.method = 'delete';
		$super(element, target, url, record, options);
	}
});

// input auto-submit
I10.Request.Input = Class.create(I10.Request.Base, {
	RUN_ON_INIT: false,
	initialize: function($super, element, url, keyName, options) {
		$super(element, url, options);
		this.keyName = keyName;
		this.value = this.element.value;
		this.element.onfocus = this.onFocus.bind(this);
		this.element.onblur = this.onBlur.bind(this);
		this.element.addClassName('active');
	},
	onFocus: function() {
		this.element.addClassName('active');
	},
	onBlur: function() {
		this.element.removeClassName('active');
		if(this.element.value == this.value) { return; }
		this.options.parameters = this.keyName+'='+this.element.value;
		this.go();
	},
	onSuccess: function(response) {
		this.element.value = response.responseText;
		this.value = this.element.value;
	}
});

// dialog box
I10.Dialog = Class.create(I10.Request.Update, {
	CLASSNAME: 'dialog',
	ID: 'dialog',
	initialize: function($super, element, url, options) {
		if(I10.Dialog.instance && !I10.Dialog.instance.close()) { return false; }
		I10.Dialog.instance = this;
		target = this.create();
		$super(element, target, url, options);
	},
	create: function() {
		if($(this.ID)) { return $(this.ID); }
		target = $(document.createElement('DIV'));
		target.hide();
		target.id = this.ID;
		target.className = this.CLASSNAME;
		document.body.appendChild(target);
		return target;
	},
	close: function() {
		this.target.hide();
		return true;
	}
});

I10.FormSubmitter = Class.create(I10.Request.Redirect, {
	initialize: function($super, form, recordName, redirectUrl, options) {
		this.recordName = recordName;
		if(!options) { options = {}; }
		options.parameters = Form.serialize(form);
		$super(form, form.action, redirectUrl, options);
	},
	onFailure: function(response) {
		if(response.status == 400) {
			this.errors = response.responseJSON;
			this.element.select('.error').each(function(e) { e.removeClassName('error'); });
			this.element.select('.errorDescription').each(function(e) { e.remove(); });
			Object.keys(this.errors).each(this.addError.bind(this));
		}
	},
	addError: function(key) {
		elementId = this.recordName+'_'+key; 
		element = $(elementId);
		element.addClassName('error');
		desc = $(document.createElement('ul'));
		desc.addClassName('errorDescription');
		this.errors[key].each(function(e) {
			item_ele = $(document.createElement('li'));
			item_ele.innerHTML = I10.Common.humanize(key)+' '+e;
			Element.insert(desc, item_ele);
		});
		Element.insert(element, {after:desc});
	}
});

// create a tooltip
I10.Tooltip = Class.create({
	ID: 'tooltip',
	initialize: function(event, element, message) {
		this.element = $(element);
		this.message = message;
		Event.observe(this.element, 'mouseover', this.onMouseover.bindAsEventListener(this));
	    Event.observe(this.element, 'mouseout', this.onMouseout.bindAsEventListener(this));
	    Event.observe(this.element, 'mousemove', this.onMousemove.bindAsEventListener(this));
		this.create();
		this.onMouseover(event);
	},
	create: function() {
		this.target = $(this.ID);
		if(this.target) { return; }
		this.target = $(document.createElement('DIV'));
		this.target.id = this.ID;
		this.target.hide();
		document.body.appendChild(this.target);
	},
	moveTo: function(event) {
		if(!event) { return; }
		var x = Event.pointerX(event);
		var y = Event.pointerY(event);
		this.target.style.left = x + 8 + 'px';
		this.target.style.top = y + 'px';
	},
	onMouseover: function(event) {
		var offset = this.element.viewportOffset();
		this.target.style.left = offset.left + 8 + 'px';
		this.target.style.top = offset.top + this.element.getHeight() + 4 + 'px';
		this.target.innerHTML = this.message;
		this.moveTo(event);
		this.target.show();
	},
	onMouseout: function(event) {
		this.target.hide();
		document.onmousemove = null;
	},
	onMousemove: function(event) {
		this.moveTo(event);
	}
});