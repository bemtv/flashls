package tv.bem {
    import flash.external.ExternalInterface;
    import flash.display.*;
    import flash.utils.setTimeout;
    import flash.events.*;
    import org.mangui.hls.utils.*;
    import flash.geom.Rectangle;
    import flash.system.Security;

    import com.globo.Player;
    import tv.bem.BemTVURLStream;
    import tv.bem.PlaybackIdHolder;

    public class BemTVPlayer extends Player {
        private var idHolder:PlaybackIdHolder;

        public function BemTVPlayer() {
            super();
            ExternalInterface.call("console.log", "BemTV player initialized!");
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
            idHolder = PlaybackIdHolder.getInstance();
            idHolder.playbackId = LoaderInfo(this.root.loaderInfo).parameters.playbackId;
        }

        override protected function _setupExternalGetters():void {
            super._setupExternalGetters();
            ExternalInterface.addCallback("getmaxBufferLength", _getmaxBufferLength);
            ExternalInterface.addCallback("getminBufferLength", _getminBufferLength);
            ExternalInterface.addCallback("getlowBufferLength", _getlowBufferLength);
        }

        override protected function _setupExternalCallers():void {
            super._setupExternalCallers();
            ExternalInterface.addCallback("playerSetmaxBufferLength", _setmaxBufferLength);
            ExternalInterface.addCallback("playerSetminBufferLength", _setminBufferLength);
            ExternalInterface.addCallback("playerSetlowBufferLength", _setlowBufferLength);
        }

        override protected function _onStageVideoState(event : StageVideoAvailabilityEvent) : void {
            super._onStageVideoState(event);
            _hls.URLstream = BemTVURLStream as Class;
        }

        override protected function _resize() : void {
            var rect : Rectangle;
            rect = ScaleVideo.resizeRectangle(_videoWidth, _videoHeight, stage.stageWidth, stage.stageHeight);
            // resize video
            if (_video) {
                _video.width = rect.width;
                _video.height = rect.height;
                _video.x = rect.x;
                _video.y = rect.y;
            } else if (_stageVideo && rect.width > 0) {
		_stageVideo.viewPort = rect;
            }
        }
    }
}
