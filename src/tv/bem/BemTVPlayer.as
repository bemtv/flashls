package tv.bem {
    import com.globo.Player;
    import flash.external.ExternalInterface;

    public class BemTVPlayer extends Player {

        public function BemTVPlayer() {
            super();
            ExternalInterface.call("console.log", "bemtv initialized.");
        };

    }
}
