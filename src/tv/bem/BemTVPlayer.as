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
            ExternalInterface.call("console.log", "BemTV Player (0.0.12)");
            idHolder = PlaybackIdHolder.getInstance();
            idHolder.playbackId = LoaderInfo(this.root.loaderInfo).parameters.playbackId;
        }

        override protected function _setupExternalGetters():void {
            super._setupExternalGetters();
            ExternalInterface.addCallback("getmaxBufferLength", _getmaxBufferLength);
            ExternalInterface.addCallback("getminBufferLength", _getminBufferLength);
            ExternalInterface.addCallback("getlowBufferLength", _getlowBufferLength);
            ExternalInterface.addCallback("getDelay", _getDelay);
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

	 private function _getDelay():Number {
	     return _hls.delay;
	 }
    }
}
