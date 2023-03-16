package {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard
	import flash.events.Event;
	import flash.media.Sound
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	import flash.net.navigateToURL
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.system.Capabilities;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.StageQuality
	import flash.display.Stage;
	import flash.display.StageOrientation;


	import so.cuo.platform.chartboost.Chartboost;
	import so.cuo.platform.chartboost.ChartboostEvent;
	

	import so.cuo.platform.admob.Admob;
	import so.cuo.platform.admob.AdmobEvent;
	import so.cuo.platform.admob.AdmobSize;
	import so.cuo.platform.admob.ExtraParameter;
	import so.cuo.platform.admob.AdmobPosition;

	public class Main extends MovieClip {

		private var birdVar: typeBird;
		private var bombs: typeBomb;
		private var mySound: Sound = new(tap);
		private var mySound2: Sound = new(smash);
		private var mySound3: Sound = new(bgMusic);
		private var pauseState: Boolean = false;
		private var flightState: Boolean = false;
		private var bombNumber: int = 3;
		private var yMove: Number = 0;

		
		private var moveScene: int = 10;
		private var currentScore: int = 0;
		private var rateApp: String = "market://details?id=<your app id>";
		private var currentScoreBest: int = 0;

		private var chartboost: Chartboost;
		private var chartboost2: Chartboost;

		private var admob: Admob;


		public var adsize2: AdmobSize;
		public var extraParam: ExtraParameter;
		public var bannerID: String = "ca-app-pub-9098235773934513/6968685584";
		public var appID: String = "533582ad2d42da456582da36";
		public var appSign: String = "d65ed84c96b5cb45411c5f681978fe751c0f9340";

		private var shared: SharedObject;
		private var result: int;
		private var timer2: Timer;

		protected const stageWidth: int = 800;
		protected const stageHeight: int = 480;


		public function Main() {

			stage.quality = StageQuality.LOW
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			admob = Admob.getInstance();
			
			if(admob.supportDevice){
				admob.setKeys(bannerID);
				admob.showBanner(Admob.BANNER,AdmobPosition.TOP_LEFT);
			}
			
			loading.addEventListener(MouseEvent.CLICK, funStart);


		}

		
		private function enterFrame(e: Event): void {
			if (!pauseState) {
				birdMovement();
				mapMovement();
			}

		}

		//tap the screen
		private function onTap(e: MouseEvent): void {

			flightState = true;

			mySound.play();

		}

		private function Deactivate(e: Event): void {
			SoundMixer.soundTransform = new SoundTransform(0, 0);


			bg.ins.stop();
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			this.removeEventListener(MouseEvent.MOUSE_UP, onTap);
			this.stage.frameRate = 0.01;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;

		}

		public function Deactivate2(e: Event): void {
			pauseState = true;

		}

		private function Activate(e: Event): void {
			
			bg.ins.play();
			addEventListener(Event.ENTER_FRAME, enterFrame);
			this.addEventListener(MouseEvent.MOUSE_UP, onTap);
			SoundMixer.soundTransform = new SoundTransform(1, 0);
			this.stage.frameRate = 30;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

		}

		public function Activate2(e: Event): void {

			timer2 = new Timer(750, 1);
			timer2.addEventListener(TimerEvent.TIMER, stopPause);
			timer2.start();

		}

		private function stopPause(e: TimerEvent): void {

			pauseState = false;
			

		}

		
		private function funReplay(event: MouseEvent): void {
			this.stage.addEventListener(Event.ACTIVATE, Activate2);
			this.stage.addEventListener(Event.DEACTIVATE, Deactivate2);

			restartGame();
		}
		
		private function funStart(event: MouseEvent): void {
			
			
			loading.visible = false;
			playGame();
			mySound3.play(0, 9999);
		}
		
		function playAd(e: TimerEvent): void {

				chartboost = Chartboost.getInstance();
				chartboost.setChartboostKeys(appID, appSign);
				chartboost.showInterstitial();


			}
		

		//If the back button is pressed, close the app
		private function handleKeys(event: KeyboardEvent): void {
			if (event.keyCode == Keyboard.BACK) {
				NativeApplication.nativeApplication.exit();
			}
		}


		//Move Player
		private function birdMovement(): void {
			if (birdVar.y < stageHeight + birdVar.height && birdVar.y > 0 - birdVar.height) // Didnt drop out of screen
			{
				if (!flightState) {
					yMove += 1.25;
				} else {
					yMove = -10;
					flightState = false;
				}
				birdVar.y += yMove;
				birdVar.rotation = birdVar.y  + 100;
			} else {

				GG();
			}
		}

		//Move bombs and power-ups
		private function mapMovement(): void {
			for (var i: int = 0; i < bombNumber; i++) {
				var conBombs = mcBombs.getChildAt(i);

				if (conBombs.hitZone2.hitTestPoint(birdVar.x, birdVar.y, true)) {
					GG();
				} 

				if (conBombs.star.hitZone3.hitTestPoint(birdVar.x, birdVar.y, true)) {
						conBombs.star.gotoAndPlay(2);
						

						currentScore++;
						txtCurrentScore.text = currentScore.toString();
				

				}

				//hitTestObject game over
				if (conBombs.hitZone.hitTestPoint(birdVar.x, birdVar.y, true)) {
					GG();
				} else {
					if (conBombs.x < 0) {

						conBombs.xxx.gotoAndPlay(2);
						conBombs.star.gotoAndStop(1);
						conBombs.xxx2.gotoAndPlay(2);
						conBombs.hitZone.gotoAndPlay(2);
						conBombs.hitZone2.gotoAndPlay(2);
						conBombs.x = 1050 - moveScene;
						conBombs.y = Math.random() * 250;
						

					} else {
						conBombs.x -= moveScene;
					}

				}
			}
		}

		//Start the game
		private function playGame(): void {
			
			this.shared = SharedObject.getLocal("myScore");
			this.result = this.shared.data.highScore;
			this.txtBest.text = this.result.toString();
			
			//place bird on stage
			birdVar = new typeBird();
			birdVar.x = stageWidth / 4;
			birdVar.y = stageHeight / 3;
			mcBird.addChild(birdVar);

			//add more bombs
			for (var i: int = 0; i < bombNumber; i++) {
				var conBombs: typeBomb = new typeBomb();
				conBombs.xxx.gotoAndPlay(2);
				conBombs.xxx2.gotoAndPlay(2);
				conBombs.hitZone.gotoAndPlay(2);
				conBombs.hitZone2.gotoAndPlay(2);
				conBombs.star.gotoAndStop(1);
				conBombs.x = (i * 350) + 1050;
				conBombs.y = Math.random() * 250;
				mcBombs.addChild(conBombs);


			}

			submenu.visible = false;

			addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onTap, false, 0, true);
			this.stage.addEventListener(Event.DEACTIVATE, Deactivate);
			this.stage.addEventListener(Event.DEACTIVATE, Deactivate2);
			this.stage.addEventListener(Event.ACTIVATE, Activate);
			this.stage.addEventListener(Event.ACTIVATE, Activate2);
			submenu.btnReplay.addEventListener(MouseEvent.CLICK, funReplay);

			if (Capabilities.cpuArchitecture == "ARM") {

				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);

			}
		}


		//Game Over
		private function GG(): void {
			
			this.stage.removeEventListener(Event.ACTIVATE, Activate2);
			this.stage.removeEventListener(Event.DEACTIVATE, Deactivate2);
			
			
			
			mySound2.play();
			birdVar.gotoAndStop(2);
			birdVar.bird.gotoAndStop(2);
			pauseState = true;
			submenu.visible = true;

			var timer: Timer = new Timer(750, 1);
			timer.addEventListener(TimerEvent.TIMER, playAd);
			timer.start();

			
			

			submenu.moreBtn.addEventListener(MouseEvent.CLICK, funMore);

			function funMore(event: MouseEvent): void {
				
				
				chartboost2 = Chartboost.getInstance();
				chartboost2.setChartboostKeys(appID, appSign);
				chartboost2.showMoreApp();
			}

			submenu.rateBtn.addEventListener(MouseEvent.CLICK, funRate);

			function funRate(event: MouseEvent): void {
				navigateToURL(new URLRequest(rateApp), "_blank");
			}

			submenu.exitBtn.addEventListener(MouseEvent.CLICK, btnExit);

			function btnExit(event: MouseEvent): void {
				NativeApplication.nativeApplication.exit();
			}

		}

		//Restart the game
		private function restartGame(): void {
			pauseState = false;
			yMove = 0;
			submenu.visible = false;

			if (this.currentScore > this.result) {
				this.result = this.currentScore;
				this.shared.data.highScore = this.result;
				this.shared.flush();
				
			}

			this.txtBest.text = this.result.toString();
			this.currentScore = 0;
			this.txtCurrentScore.text = this.currentScore.toString();

			birdVar.gotoAndStop(1);
			birdVar.bird.play();
			birdVar.x = stageWidth / 4;
			birdVar.y = stageHeight / 3;


			for (var i: int = 0; i < bombNumber; i++) {
				var conBombs = mcBombs.getChildAt(i);
				conBombs.xxx.gotoAndPlay(2);
				conBombs.xxx2.gotoAndPlay(2);
				conBombs.hitZone.gotoAndPlay(2);
				conBombs.hitZone2.gotoAndPlay(2);
				conBombs.x = (i * 350) + 1050;
				conBombs.y = Math.random() * 250;
				conBombs.star.gotoAndStop(1);
			}
		}



	}

}