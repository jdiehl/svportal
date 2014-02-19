// retrieve the admin root
ADMIN_ROOT = '/'+document.location.pathname.split('/')[1]+'/admin/';

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
I10.Request.Reload = Class.create(I10.Request.Base, {
	onSuccess:function(response) {
		window.location.reload();
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
I10.Request.Dialog = Class.create(I10.Request.Update, {
	CLASSNAME: 'dialog',
	initialize: function($super, element, target, url, options) {
		this.create(target);
		$super(element, this.target, url, options);
	},
	create: function(id) {
		this.target = $(id);
		if(this.target) { return; }
		this.target = $(document.createElement('DIV'));
		this.target.id = id;
		this.target.className = this.CLASSNAME;
		this.target.hide();
		document.body.appendChild(this.target);
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

DeleteTask = Class.create(I10.Request.DeleteRecord, {
	// constructor
	initialize: function($super, element, task_id) {
		$super(element, 'task_'+task_id, ADMIN_ROOT+'tasks/', {task:{id:task_id}});
	},
	// remove assignment has succeeded
	onSuccess: function($super, response) {
		this.target.hide();
		$('task_edit').hide();
	}
});

// update status for enrollment
UpdateStatus = Class.create(I10.Request.UpdateRecord, {
	initialize: function($super, element, enroll_id, status) {
		this.enroll_id = enroll_id;
		$super(element, 'status_'+enroll_id, ADMIN_ROOT+'enrollment/index/'+enroll_id, {enrollment:{status:status}});
	}
});

// assigns user (enrollment) to specified task (slot) and refreshes view partial
UpdateAssignment = Class.create(I10.Request.UpdateRecord, {
	// constructor
	initialize: function($super, element, record) {
		$super(element, 'slots_'+record.task_id, ADMIN_ROOT+'assignments/', {assignment:record});
	},
	// assignment has succeeded
	onSuccess: function($super, response) {
		$('user_'+this.record.assignment.enrollment_id).hide();
		element_count = $('slots_'+this.record.assignment.task_id+'_count');
		count = parseInt(element_count.innerHTML, 10);
		element_count.innerHTML = (count + 1);
	}
});

// remove assignment
DeleteAssignment = Class.create(I10.Request.DeleteRecord, {
	// constructor
	initialize: function($super, element, record) {
		$super(element, 'slots_'+record.task_id, ADMIN_ROOT+'assignments/', {assignment:record});
	},
	// remove assignment has succeeded
	onSuccess: function($super, response) {
		element = $('user_'+this.record.assignment.enrollment_id);
		if(element) { element.show(); }
		element_count = $('slots_'+this.record.assignment.task_id+'_count');
		count = parseInt(element_count.innerHTML, 10);
		element_count.innerHTML = (count - 1);
	}
});

// cycle assignment status
CycleAssignmentStatus = Class.create(I10.Request.Base, {
	initialize: function($super, element, assignment_id) {
		this.assignment_id = assignment_id;
		$super(element, ADMIN_ROOT+'assignments/cycle_status/'+assignment_id);
	},
	// cycle has succeeded
	onSuccess: function($super, response) {
		var info = response.responseJSON;
		$('slot_'+this.assignment_id).className = 's'+info.id;
		this.element.innerHTML = info.name;
	}
});

// show users list for an assignment
ShowAssignmentUsers = Class.create(I10.Request.Update, {
	initialize: function($super, element, task_id) {
		this.container = $('users_box');
		this.container.hide();
		$super(element, 'users', ADMIN_ROOT+'assignments/users/'+task_id);
	},
	onSuccess: function($super, response) {
		this.element.parentNode.parentNode.appendChild(this.container);
		this.container.show();
		// reset the search input for our list
		if(!UserSearchInput.instance) { $('search_users').focus(); }
		UserSearchInput.instance.reset(this.url);
	}
});

// display hour input

ShowAssignmentHours = Class.create(I10.Request.Update, {
	initialize: function($super, element, assignment_id) {
		this.assignment_id = assignment_id;
		this.target = $('hours_box');
		$super(element, this.target, ADMIN_ROOT+'assignments/hours/'+assignment_id);
	},
	onSuccess: function() {
		this.target.show();
	}
});	
	
// search input box
SearchInput = Class.create(I10.Request.Update, {
	RUN_ON_INIT: false,
	DELAY: 500,
	initialize: function($super, element, target, url) {
		$super(element, target, url);
		this.value = this.element.value;
		this.element.onfocus = null;
		this.element.onkeyup = this.onChange.bind(this);
		this.element.onblur = this.onBlur.bind(this);
	},
	// fire query after timer on keyup
	onChange: function() {
		if(this.timer) { clearTimeout(this.timer); }
		this.timer = setTimeout(this.onBlur.bind(this), this.DELAY);
	},
	// fire query immediately on blur
	onBlur: function() {
		clearTimeout(this.timer);
		this.timer = null;
		if(this.value == this.element.value) { return; }
		this.value = this.element.value;
		this.options.parameters = {search:this.value};
		this.go();
	},
	onSuccess: function() {
		UserSearchInput.instance = null;
	}
});

// user search input box for assignments
UserSearchInput = Class.create(SearchInput, {
	initialize: function($super, element, target) {
		UserSearchInput.instance = this;
		$super(element, target);
	},
	reset: function(url) {
		this.url = url;
		this.value = '';
		this.element.value = '';
		this.element.focus();
	},
	onSuccess: function() {}
});

// update bids
UpdateBid = Class.create(I10.Request.UpdateRecord, {
	initialize: function($super, element, tasktype_id, preference) {
		options = {};
		if(!preference) { options.method = 'delete'; }
		$super(element, null, '', {bid:{tasktype_id:tasktype_id, preference:preference}}, options);
	},
	onSuccess: function(response) {
		$('tr_task_'+this.record.bid.tasktype_id).className = 'p'+(this.record.bid.preference ? this.record.bid.preference : '');
	},
	onFailure: function(response) {
		if(response.status == 400) { alert(response.responseJSON.join("\n\n")); }
	}

});

// update availabilities
UpdateAvailability = Class.create(I10.Request.UpdateRecord, {
	initialize: function($super, element, timeslot_id, day, td_id) {
    this.timeslot_id = timeslot_id;
    this.td_id = td_id;
		$super(element, null, '', {availability:{timeslot_id:timeslot_id, day:day}}, {});
	},
	onSuccess: function(response) {
    if ($(this.td_id).className == "busy") {
      $('a' + this.td_id).innerHTML = "Free";
      $(this.td_id).className = "free";
    } else {
      $('a' + this.td_id).innerHTML = "Busy";
      $(this.td_id).className = "busy";
    }
	},
	onFailure: function(response) {
		if(response.status == 400) { alert(response.responseJSON.join("\n\n")); }
	}

});

HourCheck = Class.create({
	initialize: function() {
		this.start = { h:$('task_start_time_h'), m:$('task_start_time_m') };
		this.end = { h:$('task_end_time_h'), m:$('task_end_time_m') };
		this.hours = { h:$('task_hours_h'), m:$('task_hours_m') };
	},
	updateHours: function(element) {
		var h = this.end.h.value - this.start.h.value;
		var m = this.end.m.value - this.start.m.value;
		if(m < 0) { m += 60; h -= 1; }
		// validation
		if(!this.validate(h >= 0)) { return; }
		// update
		if(this.hours.h.value != h) {
			this.hours.h.value = h;
			new Effect.Highlight(this.hours.h);
		}
		if(this.hours.m.value != m) {
			this.hours.m.value = m;
			new Effect.Highlight(this.hours.m);
		}
	},
	validate: function(valid) {
		if(valid) {
			this.start.h.removeClassName('error');
			this.start.m.removeClassName('error');
			this.end.h.removeClassName('error');
			this.end.m.removeClassName('error');
		} else {
			this.start.h.addClassName('error');
			this.start.m.addClassName('error');
			this.end.h.addClassName('error');
			this.end.m.addClassName('error');
		}
		return valid;
	}
});
HourCheck.getInstance = function() {
	if(!HourCheck.instance) { HourCheck.instance = new HourCheck(); }
	return HourCheck.instance;
}