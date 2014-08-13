package tv.bem {
    import flash.external.ExternalInterface;
    import flash.display.*;
    import flash.utils.setTimeout;
    import flash.events.*;

    import com.globo.Player;
    import tv.bem.BemTVURLStream;
    import tv.bem.PlaybackIdHolder;

    public class BemTVPlayer extends Player {
        private var idHolder:PlaybackIdHolder;

        public function BemTVPlayer() {
            super();
            ExternalInterface.call("console.log", "BemTV player initialized.");
            idHolder = PlaybackIdHolder.getInstance();
            idHolder.playbackId = LoaderInfo(this.root.loaderInfo).parameters.playbackId;
        }

        override protected function _setupExternalGetters():void {
            super._setupExternalGetters();
            ExternalInterface.addCallback("getmaxBufferLength", _getmaxBufferLength);
            ExternalInterface.addCallback("getminBufferLength", _getminBufferLength);
            ExternalInterface.addCallback("getlowBufferLength", _getlowBufferLength);
            ExternalInterface.addCallback("getEntropy", _getEntropy);
        }

        override protected function _setupExternalCallers():void {
            super._setupExternalCallers();
            ExternalInterface.addCallback("playerSetmaxBufferLength", _setmaxBufferLength);
            ExternalInterface.addCallback("playerSetminBufferLength", _setminBufferLength);
            ExternalInterface.addCallback("playerSetlowBufferLength", _setlowBufferLength);
            ExternalInterface.addCallback("playerSetEntropy", _setEntropy);
        }

        override protected function _onStageVideoState(event : StageVideoAvailabilityEvent) : void {
            super._onStageVideoState(event);
            _hls.URLstream = BemTVURLStream as Class;
        }

        protected function _setEntropy(num:Number):void {
            _hls._manifestLoader.entropy = num;
        }

		protected function _getEntropy():Number {
			return _hls._manifestLoader.entropy;
		}
    }
}
