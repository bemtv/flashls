package com.globo {

    import org.mangui.chromeless.ChromelessPlayer;
    import org.mangui.hls.*;
    import org.mangui.hls.utils.Log;
    import org.mangui.hls.event.HLSEvent;
    import org.mangui.hls.event.HLSError;

    import org.mangui.hls.model.Level;

    import flash.display.*;
    import flash.system.Security;
    import flash.media.Video;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.media.StageVideoAvailability;
    import flash.utils.setTimeout;

    public class Player extends ChromelessPlayer {
        private var _url:String;
        private var playbackId:String;
        private var _timeHandlerCalled:Number = 0;
	private var _totalErrors:Number = 0;

        public function Player() {
            super();
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
            this.playbackId = LoaderInfo(this.root.loaderInfo).parameters.playbackId;
            ExternalInterface.call("console.log", "HLS Initialized (0.1.8 - id: " + this.playbackId + ")");
            setTimeout(flashReady, 50);
        }

        override protected function _setupExternalGetters():void {
            ExternalInterface.addCallback("globoGetDuration", _getDuration);
            ExternalInterface.addCallback("globoGetState", _getPlaybackState);
            ExternalInterface.addCallback("globoGetPosition", _getPosition);
            ExternalInterface.addCallback("globoGetType", _getType);
            ExternalInterface.addCallback("globoGetLevel", _getLevel);
            ExternalInterface.addCallback("globoGetLevels", _getLevels);
            ExternalInterface.addCallback("globoGetbufferLength", _getbufferLength);
            ExternalInterface.addCallback("globoGetAutoLevel", _getAutoLevel);
            ExternalInterface.addCallback("globoGetLastProgramDate", _getLastProgramDate);
            ExternalInterface.addCallback("globoGetDroppedFrames", _getDroppedFrames);
            ExternalInterface.addCallback("globoRemoveLevel", _removeLevel);
        }

        override protected function _setupExternalCallers():void {
            ExternalInterface.addCallback("globoPlayerLoad", _load);
            ExternalInterface.addCallback("globoPlayerPlay", _play);
            ExternalInterface.addCallback("globoPlayerPause", _pause);
            ExternalInterface.addCallback("globoPlayerResume", _resume);
            ExternalInterface.addCallback("globoPlayerSeek", _seek);
            ExternalInterface.addCallback("globoPlayerStop", _stop);
            ExternalInterface.addCallback("globoPlayerVolume", _volume);
            ExternalInterface.addCallback("globoPlayerSetLevel", _setLevel);
            ExternalInterface.addCallback("globoPlayerSmoothSetLevel", _smoothSetLevel);
            ExternalInterface.addCallback("globoPlayerSetflushLiveURLCache", _setflushLiveURLCache);
            ExternalInterface.addCallback("globoPlayerSetStageScaleMode", _setScaleMode);
            ExternalInterface.addCallback("globoPlayerSetmaxBufferLength", _setmaxBufferLength);
            ExternalInterface.addCallback("globoPlayerSetminBufferLength", _setminBufferLength);
            ExternalInterface.addCallback("globoPlayerSetlowBufferLength", _setlowBufferLength);
        };

        private function _triggerEvent(eventName: String, param:String=null):void {
            var event:String = playbackId + ":" + eventName;
            ExternalInterface.call('Clappr.Mediator.trigger', event, param);
        };

        protected function flashReady(): void {
            _triggerEvent('flashready');
        };

        override protected function _getLevels() : Vector.<Level> {
            var levels : Vector.<Level> = new Vector.<Level>();
            for each (var level : Level in _hls.levels) {
                var newLevel : Level = new Level();
                newLevel.bitrate = level.bitrate;
                newLevel.averageduration = level.averageduration;
                levels.push(newLevel);
            }
            return levels;
        };

        override protected function _onStageVideoState(event : StageVideoAvailabilityEvent) : void {
            var available : Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
            _hls = new HLS();
            _hls.stage = stage;
            _hls.addEventListener(HLSEvent.ERROR, _errorHandler);
            _hls.addEventListener(HLSEvent.MEDIA_TIME, _mediaTimeHandler);
            _hls.addEventListener(HLSEvent.PLAYBACK_STATE, _stateHandler);
            _hls.addEventListener(HLSEvent.FRAGMENT_LOADED, _fragmentLoadedHandler);

            if (available && stage.stageVideos.length > 0) {
                _stageVideo = stage.stageVideos[0];
                _stageVideo.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
                _stageVideo.attachNetStream(_hls.stream);
            } else {
                _video = new Video(stage.stageWidth, stage.stageHeight);
                addChild(_video);
                _video.smoothing = true;
                _video.attachNetStream(_hls.stream);
            }
            stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);

            var autoLoadUrl : String = root.loaderInfo.parameters.url as String;
            if (autoLoadUrl != null) {
                _autoLoad = true;
                _load(autoLoadUrl);
            }
        };

        override protected function _stateHandler(event : HLSEvent) : void {
            _triggerEvent('playbackstate', event.state);
        };

        override protected function _fragmentLoadedHandler(event : HLSEvent) : void {
            _triggerEvent('fragmentloaded');
        };


        override protected function _mediaTimeHandler(event : HLSEvent) : void {
            _duration = event.mediatime.duration;
            _media_position = event.mediatime.position;
            _timeHandlerCalled += 1;

            var videoWidth : int = _video ? _video.videoWidth : _stageVideo.videoWidth;
            var videoHeight : int = _video ? _video.videoHeight : _stageVideo.videoHeight;

            if (videoWidth && videoHeight) {
                var changed : Boolean = _videoWidth != videoWidth || _videoHeight != videoHeight;
                if (changed) {
                    _videoHeight = videoHeight;
                    _videoWidth = videoWidth;
                    _resize();
                    if (videoHeight >= 720) {
                        _triggerEvent('highdefinition', "true");
                    } else {
                        _triggerEvent('highdefinition', "false");
                    }
                }
            }

            if (_timeHandlerCalled == 10) {
                _triggerEvent('timeupdate', _duration + "," + _hls.position);
                _timeHandlerCalled = 0;
            }
        };

        override protected function _load(url : String) : void {
            _url = url;
            super._load(url);
        };

        override protected function _errorHandler(event : HLSEvent) : void {
	    if (event.error.code == HLSError.FORBIDDEN) {
		CONFIG::LOGGING { Log.info("Error, FORBIDDEN.") }
		 _triggerEvent('playbackerror');
		_stop();
	    } else if (event.error.code == HLSError.MANIFEST_LOADING_CROSSDOMAIN_ERROR) {
		CONFIG::LOGGING { Log.info("Error, CROSS DOMAIN.") }
	        _triggerEvent('playbackerror');
		_stop();
	    } else {
		if (_totalErrors < 4) {
		    CONFIG::LOGGING { Log.info("Unknown error, rebooting.") }
		    _totalErrors++;
		    _load(_url);
		    _play();
		} else {
		    CONFIG::LOGGING { Log.info("Error, aborting.") }
	            _triggerEvent('playbackerror');
		    _stop();
		}
	    }
        };

        private function _getDroppedFrames() : int {
            return _hls.droppedFrames;
        };

        private function _removeLevel(pos:Number):void {
            _hls.removeLevel(pos);
        };

        private function _setScaleMode(mode:String):void {
            stage.scaleMode = mode;
            _onStageResize();
        };

        private function _getLastProgramDate():Number {
            return _hls.lastProgramDate;
        };
   }
}
