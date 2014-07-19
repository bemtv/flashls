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
        };

        override protected function _onStageVideoState(event : StageVideoAvailabilityEvent) : void {
            super._onStageVideoState(event);
            _hls.URLstream = BemTVURLStream as Class;
        }
    }
}