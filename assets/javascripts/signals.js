
var Signals = {timeActive: 10, timeInactive: 120, delayInactive: 100 };//en seconde
Signals.check = function(pe) {
	pe.stop();
	 new Ajax.Request('http://'+Signals.prefix+'/signals/check', {
	 	method:'get'
	 });
};

Signals.inactive = function() {
	window.clearTimeout(Signals.checkMouseId);
	Signals.time = Signals.timeInactive;
	console.info("User became Inactive");
};
Signals.active = function() {
	window.clearTimeout(Signals.checkMouseId);
	if(Signals.time != Signals.timeActive) {
		Signals.time = Signals.timeActive;
		console.info("User became Active");
		Signals.checkStart();
	}
	Signals.checkMouse();
};
Signals.checkStart = function() {
	if (Signals.pe)
		Signals.pe.stop();
	Signals.pe = new PeriodicalExecuter(Signals.check, Signals.time);
};
Signals.checkMouse = function() {
	Signals.checkMouseId = Signals.inactive.delay(Signals.delayInactive);
}

Signals.init = function(pref, options) {
try{
	options = options || {};
	if(options['timeActive'])
		Signals.timeActive = options['timeActive'];
	if(options['timeInactive'])
		Signals.timeInactive = options['timeInactive'];

	Signals.time = Signals.timeActive;
	Signals.prefix = pref || '';

	Ajax.Responders.register({
		onCreate: function() {
			Signals.pe.stop();
		},
		onComplete: function(request ,response) {
			if (response.responseJSON) {
				if (response.responseJSON.signals) {
					Signals.signals(response.responseJSON.signals);
					delete response.responseJSON.signals;
				}

			}
			if (Signals.stop_by_hand == undefined)
				Signals.checkStart();
		}
	});
	Signals.checkStart();
	Signals.checkMouse();
	Event.observe(document, 'keydown', Signals.active);
	Event.observe(document, 'mousemove', Signals.active);
	Event.observe(document, 'click', Signals.active);
}catch(e){console.log(e);}
};

Signals.signals = function(jsond) {
	var signals = jsond;
	if(signals['e']) {
		console.log('Signales up an error ==> ' +signals['e']);
	}
	if(signals['u']) {
		signals['u'].each(function(signal) {
			if(signal['type']) {
				console.log('fireEvent signals:'+signal.type);
				document.fire('signals:'+signal.type, {params:signal.params, timeserver: signals['t'], crud: signal.crud});
			}
		});
	}

	if (Signals.stop_by_hand == undefined)
		Signals.checkStart();
};
Signals.registre = [];
Signals.regEvent = function(ev, callback) {
	console.log('Document observe  signals:'+ev);
	document.observe('signals:'+ev, callback);
	Signals.registre.push([ev, callback]);
};
Signals.delEvent = function(ev, callback) {
	console.log('Document delete observe  signals:'+ev);
	Event.stopObserve(document, 'signals:'+ev, callback);
	Signals.registre.without([ev, callback]);
};
//clean event and callback
Signals.clean = function() {
	Signals.registre.each(function(dev) {
		Event.stopObserve(document, 'signals:'+dev[0], dev[1]);
	});
	Signals.registre = [];
};
Signals.change_check_time = function(newTime) {
	Signals.timeActive = newTime;
};
Signals.change_check_time_inactive = function(newTime) {
	Signals.timeInactive = newTime;
};
Signals.change_inactive_time = function(newTime) {
	Signals.delayInactive = newTime;
};

Signals.desactive_check = function() {
	Signals.pe.stop();
	Signals.stop_by_hand = true;
};

Signals.resactive_check = function() {
	Signals.checkStart();
	Signals.stop_by_hand = undefined;
};
/*
Signals.init(pref);
OR
Signals.init(pref, {timeActive:XX, timeInactive:XXXX});
*/

