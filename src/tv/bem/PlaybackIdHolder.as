package tv.bem {
    import flash.external.ExternalInterface;

    public class PlaybackIdHolder {
        private static var instance:PlaybackIdHolder;
        private var _playbackId:String;

        public function PlaybackIdHolder() {
            if (instance) {
                throw new Error("use getInstance()");
            }
            instance = this;
        }

        public static function getInstance():PlaybackIdHolder {
            if (!instance) {
                new PlaybackIdHolder();
            }
            return instance;
        }

        public function set playbackId(id:String):void {
            ExternalInterface.call("console.log", "setting playback id: " + id);
            _playbackId = id;
        }

        public function get playbackId():String {
            ExternalInterface.call("console.log", "returning playback id: " + _playbackId);
            return _playbackId;
        }
    }
}
