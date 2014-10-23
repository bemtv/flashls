package tv.bem {
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.external.ExternalInterface;
    import org.mangui.chromeless.JSURLStream;
    import tv.bem.PlaybackIdHolder;

    public class BemTVURLStream extends JSURLStream {
        private var idHolder:PlaybackIdHolder;
        private var playbackId:String;

        public function BemTVURLStream() {
            super();
            idHolder = PlaybackIdHolder.getInstance();
            playbackId = idHolder.playbackId;
            ExternalInterface.addCallback("resourceLoaded", resourceLoaded);
        }

        override public function load(request:URLRequest):void {
            _triggerEvent("requestresource", request.url);
            dispatchEvent(new Event(Event.OPEN));
        }

        private function _triggerEvent(eventName: String, param:String=null):void {
            var event:String = playbackId + ":" + eventName;
            ExternalInterface.call('Clappr.Mediator.trigger', event, param);
        }

        override protected function resourceLoadingError() : void {
            _triggerEvent("decodeerror");
        }

        override protected function resourceLoadingSuccess() : void {
            _triggerEvent("decodesuccess");
        }

    }
}

