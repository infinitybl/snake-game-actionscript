package //BY: PHILLIP PHAM
//Sources I got help from:
//http://code.tutsplus.com/tutorials/build-a-classic-snake-game-in-as3--active-10973
//http://www.freeactionscript.com/tag/make-enemies-follow-player/
//http://www.freeactionscript.com/tag/enemy-ai-in-flash/
//http://stackoverflow.com/questions/21104893/make-movie-clip-enemy-follow-player-instead-of-walking-on-set-xy-axis-flash
//http://stackoverflow.com/questions/28129568/make-an-enemy-chase-a-character-as-the-character-moves-as3
//http://blog.anselmbradford.com/2009/09/10/this-isnt-right-movieclip-nested-inside-button-throwing-null-object-reference-error-in-flash-cs4/
//http://stackoverflow.com/questions/9021863/how-to-create-exit-button-in-flash-application
//https://srdragos.wordpress.com/2013/01/25/build-a-classic-snake-game-in-actionscript-2-0/
//http://rembound.com/articles/creating-a-snake-game-tutorial-with-html5
//http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7f8a.html
//https://forums.adobe.com/thread/1058277
{
	import flash.display.MovieClip;
	import flash.ui.Keyboard; //allows flash to use keyboard
	import flash.events.*; //allows flash to handle events
	import flash.utils.Timer; //allows flash to use timers
	import flash.text.*; //allows flash to use text
	import flash.system.fscommand; //allows flash to use system commands
	import flash.media.*; //alows flash to use music
	
	public class MainSnake extends MovieClip
	{
		var speed:int;      //variable for speed of the snake
		var score:int = 0;  //variable for score (increase by 2 everytime you get a food)
		var vx:Number = 0;  //variable for x velocity for snake
		var vy:Number = 0;  //variable for y velocity for snake
		
		var txtScore:TextField; //variable for text field to display the score
		var txtFormat:TextFormat; //variable for allow text to have a certain format
		var pauseText:PauseText; //variable to display the word pause when game is paused
		
		//variables for food
		var food:Food; //one piece of food
		var foodArray:Array = new Array(); //array to hold all food instances
		var foodCount:int = 2; //variable for more food powerup to check if player collected two food in 
		//order to spawn more food (this is to avoid too much food on screen at once)
		
		//variables for snake
		var head:SnakePart; //variable for head (of type SnakePart)
		var bodyPart:SnakePart; //variable for a bodypart (of type SnakePart)
		var tail:SnakePart; //variable for tail (of type SnakePart)
		var snakeDirection:String = ""; //variable to get snake direction from keycodes
		var snake:Array = new Array(); //initilizes array to contain snake head, body parts, and tail
		
		//variables for enemies
		var enemyTimer:Timer; //timer to add enemies
		//i needed to make each enemy facing a different direction have a different class 
		//so that the for loop can identify them and move it accordingly
		var enemy1:Enemy1; //enemy facing downwards
		var enemy2:Enemy2; //enemy facing to the right
		var enemy3:Enemy3; //enemy facing to the left
		var enemy4:Enemy4; //enemy facing upwards
		var enemyType:Number; //variable to determine what enemy you get
		var enemyArray:Array = new Array(); //array holding enemies 
		
		//variables for powerups
		var noEnemy:NoEnemy; //removes all enemies from screen and stop enemies from spawning
		var invincible:Invincible; //can't be affected by enemies and stops you from dying when you hit a wall or tail
	    var foodMultiplier:Multiply; //for every one food you get, it multiplies by 2 and you get two body parts
		var moreFood:MoreFood; //adds more than one food on the screen at a time
		var slow:Slow; //slows down the snake
		var maxBullet:MaxBullet; //allows snake to shoot without losing socre
		
		//powerup symbols to display if you have a powerup
		var noEnemySymbol:NoEnemySymbol; 
		var invincibleSymbol:InvincibleSymbol;
		var foodMultiplierSymbol:MultiplySymbol;
		var moreFoodSymbol:MoreFoodSymbol;
		var slowSymbol:SlowSymbol;
		var maxBulletSymbol;

		//variables to check if player has a powerup
		//we set them to false at the beginning of the game
		var snakeHasNoEnemy:Boolean = false;
		var snakeHasInvincible:Boolean = false;
		var snakeHasMultiply:Boolean = false;
		var snakeHasMoreFood:Boolean = false;
		var snakeHasSlow:Boolean = false;
		var snakeHasMaxBullet:Boolean = false;
		
		var addPowerupTimer:Timer; //timer to add a new powerup every few seconds
		var powerupLengthTimer:Timer; //timer to determine how long a powerup runs
		var getPowerupLimit:Timer; //timer to show how long powerup stays on screen before disapearing
		var powerup:Number; //variable to generate random number that determines what powerup you get
	 
	 	//sound channels to run sounds (we add a new sound channel for each sound so that there are no overlaps)
		var sc:SoundChannel = new SoundChannel();
		var sc1:SoundChannel = new SoundChannel();
		var sc2:SoundChannel = new SoundChannel();
		var sc3:SoundChannel = new SoundChannel();
		var sc4:SoundChannel = new SoundChannel();
		var sc5:SoundChannel = new SoundChannel();
		var sc6:SoundChannel = new SoundChannel();
		var sc7:SoundChannel = new SoundChannel();
		var sc8:SoundChannel = new SoundChannel();
		var trans:SoundTransform = new SoundTransform(0.5, -0.5); //this makes the growSound more quiet because it's too loud
		var music1:Music1; //background music for level 1
		var music2:Music2; //background music for level 2
		var music3:Music3; //background music for level 3
		var mainMusic:MainMusic; //background music for main menu
		var loseMusic:LoseMusic; //background music for game over
		var growSound:GrowSound;
		var shrinkSound:ShrinkSound;
		var shootSound:ShootSound;
		var hitSound:HitSound;
		var powerupSound:PowerupSound;
		var powerupMusic:PowerupMusic; //background music for when you have a powerup
		var enemySound:EnemySound;
		var pauseSound:PauseSound; //sound everytime you click a button (not just for pause)
		
		var pauseBtn:Pause; //pause button
		var resumeBtn:Play2; //resume button
		var replayBtn:Replay; //replay button
		var onlyOnce:Boolean = true; //variable to avoid the reset function from running more than once each game
		
		var prevSeg:SnakePart; //variable to determine previous snakepart
		var prevSeg2:SnakePart; //variable to determine previous snaepart for another for loop
		var nextSeg:SnakePart; //variable to determine next snakepart
		
		var levelType:int = 0; //variable to determine what level you are on
		
		var playBtn:Play; //play button
		var exitBtn:Exit; //exit button
		var infoBtn:Info; //instructions button
		var nextBtn:Next; //next button
		var prevBtn:Previous; //previous button
		//var scoreBtn:Score; //high scores button
		
		var ex:int; //velocity for enemy x movement
		var ey:int; //velocity for enemy y movement
		var backBtn:BackBtn; //back button for instructions frame (to go back to main menu)
		var backBtn2:BackBtn; //back button for level selection frame 
		var backBtn3:BackBtn; //back button for instructions 2 frame
		var onlyMusic:Boolean = false; //boolean so that main menu music only runs once (stops another main menu music from starting)
		
		//bullet variables for all the bullet directions (snake reason as enemies)
		var bullet1:Bullet1;
		var bullet2:Bullet2;
		var bullet3:Bullet3;
		var bullet4:Bullet4;
		var bulletArray:Array = new Array(); //array to hold all bullet instances
		
		public function Main():void
		{
			//checks what level the user selected and changed value types according to it
			if (levelType == 1) 
			{
				getPowerupLimit = new Timer(15000, 0); //limit is more longer 
				getPowerupLimit.addEventListener(TimerEvent.TIMER, onLimit); //adds event listener for the limit timer
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onShoot); //adds event listener for snake to shoot
				music1 = new Music1(); 
				sc.stop(); //stops the main menu music
				sc = music1.play(0, 9999); //plays background music 1 a lot of times (9999 times)
				speed = 12; //snake goes slower
				ex = 6; //enemies move slower
				ey = 6;
				addPowerupTimer = new Timer(20000, 0); //powerups spawn more frequently
				enemyTimer = new Timer(9000, 0); //enemes spawn less frequently 
				powerupLengthTimer = new Timer(40000, 0); //powerups last much longer
			}
			else if (levelType == 2)
			{
				getPowerupLimit = new Timer(10000, 0); //limit is shorter
				getPowerupLimit.addEventListener(TimerEvent.TIMER, onLimit);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onShoot);
				music2 = new Music2();
				sc.stop();
				sc = music2.play(0, 9999);
				speed = 14; //snake moves faster 
				ex = 8; //enemies move faster 
				ey = 8;
				addPowerupTimer = new Timer(30000, 0); //powerups spawn more frequently
				enemyTimer = new Timer(6000, 0); //enemies spawn more frequently 
				powerupLengthTimer = new Timer(30000, 0); //powerups last less longer
			}
			else if (levelType == 3)
			{
				getPowerupLimit = new Timer(5000, 0);
				getPowerupLimit.addEventListener(TimerEvent.TIMER, onLimit);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onShoot);
				music3 = new Music3();
				sc.stop();
				sc = music3.play(0, 9999);
				speed = 16; 
				ex = 10; 
				ey = 10;
				addPowerupTimer = new Timer(40000, 0); 
				enemyTimer = new Timer(3000, 0);
				powerupLengthTimer = new Timer(20000, 0);
			}
			
			//adds pause button
			pauseBtn = new Pause();
			pauseBtn.x = stage.stageWidth - 25;
			pauseBtn.y = 25;
			addChild(pauseBtn);
			
			//adds snake head to the middle of the stage
			//and pushes it to array
			head = new SnakePart();
			head.x = stage.stageWidth / 2;
			head.y = stage.stageHeight / 2;
			addChild(head);
			head.gotoAndStop(1); //head (facing up) is at frame 1 in snakePart object
			snake.push(head);
			
			//adds a snake body part to the stage and pushes
			//it to the array (position is dependent on head)
			bodyPart = new SnakePart();
			bodyPart.x = snake[0].x;
			bodyPart.y = snake[0].y;
			addChild(bodyPart);
			bodyPart.gotoAndStop(11); //body (facing up) is at fram 11
			snake.push(bodyPart);
			
			//adds snake tail to the stage and pushes
			//it to the array
			tail = new SnakePart();
			tail.x = snake[1].x; //the tail is under the body part
			tail.y = snake[1].y;
			addChild(tail);
			tail.gotoAndStop(5);
			snake.push(tail);
			
			//text format for txtScore
			txtFormat = new TextFormat();
			txtFormat.font = "Tw Cen MT Condensed Extra Bold";
			txtFormat.color = 000000;
			txtFormat.size = 28;
			
			//adds score display to stage
			txtScore = new TextField();
			txtScore.defaultTextFormat = txtFormat;
			txtScore.x = 50;
			txtScore.y = 50;
			txtScore.width = 100;
			addChild(txtScore);
			
			enemyTimer.start(); //starts the enemy timer to add enemies to screen
			
			addPowerupTimer.start(); //starts powerup timer to add powerups to screen
			
			//adds one food to the stage
			addFood();
			
			addPowerupTimer.addEventListener(TimerEvent.TIMER, onPowerup); //calls onPowerup function for every tick of the timer
			powerupLengthTimer.addEventListener(TimerEvent.TIMER, onPowerupLength); //calls onPowerupLength function everytime you get a powerup
			enemyTimer.addEventListener(TimerEvent.TIMER, onEnemyTick); //calls onEnemyTick function
			pauseBtn.addEventListener(MouseEvent.CLICK, onPause); //calls onPause function
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyD); //calls onKeyD function every time a key is pressed
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyU); //calls onKeyU function every time a key is not pressed
			stage.addEventListener(Event.ENTER_FRAME, gameLoop); //calls gameLoop every 24 seconds
		}
		
		//functions removes powerup if player did not get in time
		public function onLimit(e:TimerEvent):void
		{
			getPowerupLimit.reset(); //resets limit timer 
			
			//removes powerup if player did not get in time
			if (noEnemy != null && stage.contains(noEnemy))
			{
				removeChild(noEnemy);
				noEnemy = null;
			}
			else if (invincible != null && stage.contains(invincible))
			{
				removeChild(invincible);
				invincible = null;
			}
			else if (foodMultiplier != null && stage.contains(foodMultiplier))
			{
				removeChild(foodMultiplier);
				foodMultiplier = null;
			}
			else if (moreFood != null && stage.contains(moreFood))
			{
				removeChild(moreFood);
				moreFood = null;
			}
			else if (slow != null && stage.contains(slow))
			{
				removeChild(slow);
				slow = null;
			}
			else if (maxBullet != null && stage.contains(maxBullet))
			{
				removeChild(maxBullet);
				maxBullet = null;
			}
		}
		
		//function allows snake to shoot bullets
		public function onShoot(e:KeyboardEvent):void
		{
			//checks to see if player pressed spacebar and if score is greater than 0
			if (e.keyCode == Keyboard.SPACE && score > 0)
			{
				if (snakeHasMaxBullet == false)
				{
					score--;
				}
				shootSound = new ShootSound(); //plays shoot sound
				sc7 = shootSound.play();
				//adds a bullet to the stage depending on the position of the head
				//(i made a different type of bullet from 1 to 4 on a specific direction)
				if (snake[0] != null && snake[0].currentFrame == 1)
				{
					//up
					bullet1 = new Bullet1();
					bullet1.x = snake[0].x;
					bullet1.y = snake[0].y - 30; //in front of the head
					addChild(bullet1);
					bulletArray.push(bullet1);
				}
				else if (snake[0] != null && snake[0].currentFrame == 2)
				{
					//right
					bullet2 = new Bullet2();
					bullet2.x = snake[0].x + 30;
					bullet2.y = snake[0].y;
					addChild(bullet2);
					bulletArray.push(bullet2);
				}
				else if (snake[0] != null && snake[0].currentFrame == 3)
				{
					//down
					bullet3 = new Bullet3();
					bullet3.x = snake[0].x;
					bullet3.y = snake[0].y + 30;
					addChild(bullet3);
					bulletArray.push(bullet3);
				}
				else if (snake[0] != null && snake[0].currentFrame == 4)
				{
					//left
					bullet4 = new Bullet4();
					bullet4.x = snake[0].x - 30;
					bullet4.y = snake[0].y;
					addChild(bullet4);
					bulletArray.push(bullet4);
				}
			}
		}
		
		//function pauses the game
		public function onPause(e:MouseEvent):void
		{
			//stops timers
			powerupLengthTimer.stop();
			enemyTimer.stop();
			addPowerupTimer.stop();
			getPowerupLimit.stop();
			pauseSound = new PauseSound(); //plays pause sound
			sc5 = pauseSound.play();
			pauseText = new PauseText(); //adds the pause text to display
			pauseText.x = stage.stageWidth / 2;
			pauseText.y = stage.stageHeight / 2;
			addChild(pauseText);
			stage.frameRate = 0; //sets the stage frame rate to zero (stops gameLoop from running)
			//NOTE: we got the pause idea from https://forums.adobe.com/thread/1058277
			removeChild(pauseBtn); //removes pause button
			resumeBtn = new Play2(); //adds resume button
			resumeBtn.x = stage.stageWidth - 25;
			resumeBtn.y = 25;
			addChild(resumeBtn);
			pauseBtn.removeEventListener(MouseEvent.CLICK, onPause); //removes event listener for pause
			resumeBtn.addEventListener(MouseEvent.CLICK, onResume); //adds event lister for resume
		}
		
		//function resumes the game
		public function onResume(e:MouseEvent):void
		{
			//resumes timers
			powerupLengthTimer.start();
			enemyTimer.start();
			addPowerupTimer.start();
			getPowerupLimit.start();
			pauseSound = new PauseSound();
			sc5 = pauseSound.play(); //plays resume sound (same thing with pause sound)
			removeChild(pauseText);
			stage.frameRate = 24; //sets frameRate back to 24 (have to click screen in order to move too)
			removeChild(resumeBtn); //removes resume button
			pauseBtn = new Pause(); //adds pause button back
			pauseBtn.x = stage.stageWidth - 25;
			pauseBtn.y = 25;
			addChild(pauseBtn);
			pauseBtn.addEventListener(MouseEvent.CLICK, onPause);
			resumeBtn.removeEventListener(MouseEvent.CLICK, onResume);
		}
		
		//This function will add food at a random position to the stage
		public function addFood():void 
		{
			//checks to see if player has morefood powerup
			//and adds two foods to stage
			if (snakeHasMoreFood == true)
			{
				if (foodCount == 2) //checks to see if player got the last two food before adding another
				{
					foodCount = 0; //resets the foodCount back to 0 so that player has to get two food
					food = new Food();
					food.x = 50 + Math.random()*(stage.stageWidth - 200);
					food.y = 50 + Math.random()*(stage.stageHeight - 200);
					addChild(food);
					foodArray.push(food);
					food = new Food();
					food.x = 50 + Math.random()*(stage.stageWidth - 200);
					food.y = 50 + Math.random()*(stage.stageHeight - 200);
					addChild(food);
					foodArray.push(food);
				}
			}
			else if (snakeHasMoreFood == false) //otherwise just adds one food
			{
				food = new Food();
				food.x = 50 + Math.random()*(stage.stageWidth - 200);
				food.y = 50 + Math.random()*(stage.stageHeight - 200);
				addChild(food);
				foodArray.push(food);
			}	
		}
		
		//this function will reset the game
		public function reset():void 
		{
			sc.stop(); //stops background music
			
			//disables all powerups in use
			snakeHasNoEnemy = false;
			snakeHasInvincible = false;
			snakeHasMultiply = false;
			snakeHasMoreFood = false;
			snakeHasSlow = false;
			snakeHasMaxBullet = false;
			
			//resets all timers
			powerupLengthTimer.reset();
			enemyTimer.reset();
			addPowerupTimer.reset();
			
			//removes all bullets from stage and array
			for (var l:int = bulletArray.length - 1; l >= 0; l--)
			{
				removeChild(bulletArray[l]);
				bulletArray.splice(l, 1);
			}
			
			//removes all enemies on stage and array
			for (var k:int = enemyArray.length - 1; k >= 0; k--)
			{
				if (enemyArray[k] != null)
				{
					removeChild(enemyArray[k]);
					enemyArray[k] = null;
					enemyArray.splice(k, 1);
				}
				
			}
			
			//removes all snake parts on stage and array
			for (var i:int = snake.length - 1; i >= 0; i--)
			{ 
				if (snake[i] != null)
				{
					removeChild(snake[i]);
					snake[i] = null;
					snake.splice(i, 1);
				}
			}
			
			
			//removes all food on stage and array
			for (var h:int = foodArray.length - 1; h >= 0; h--)
			{
				removeChild(foodArray[h]);
				foodArray.splice(h, 1);
			}
			
			//removes all powerups on stage
			if (invincible != null && stage.contains(invincible))
			{
				removeChild(invincible);
				invincible = null;
			}
			else if (noEnemy != null && stage.contains(noEnemy))
			{
				removeChild(noEnemy);
				noEnemy = null;
			}
			else if (slow != null && stage.contains(slow))
			{
				removeChild(slow);
				slow = null;
			}
			else if (moreFood != null && stage.contains(moreFood))
			{
				removeChild(moreFood);
				moreFood = null;
			}
			else if (foodMultiplier != null && stage.contains(foodMultiplier))
			{
				removeChild(foodMultiplier);
				foodMultiplier = null;
			}
			else if (maxBullet != null && stage.contains(maxBullet))
			{
				removeChild(maxBullet);
				maxBullet = null;
			}
			
			//removes pause button
			if (pauseBtn != null && stage.contains(pauseBtn))
			{
				removeChild(pauseBtn);
				pauseBtn = null;
			}
			
			//removes score display
			if (txtScore != null && stage.contains(txtScore))
			{
				removeChild(txtScore);
				txtScore = null;
			}
			
			//removes anything left over
			while (stage.numChildren > 1)
			{
  				stage.removeChildAt(0);
			}
			
			
			vx = 0; //resets the x and y velocities back to 0
			vy = 0;
			
			//resets snake direction
			snakeDirection = "";
			
			gotoAndStop(8); //goes to game over screen
			
			loseMusic = new LoseMusic(); //plays lose music
			sc3 = loseMusic.play(0, 9999);
			
			//removes event listeners
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onShoot); 
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyD); 
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyU); 
			addPowerupTimer.removeEventListener(TimerEvent.TIMER, onPowerup); 
			powerupLengthTimer.removeEventListener(TimerEvent.TIMER, onPowerupLength); 
			enemyTimer.removeEventListener(TimerEvent.TIMER, onEnemyTick);  
			stage.removeEventListener(Event.ENTER_FRAME, gameLoop);
			getPowerupLimit.removeEventListener(TimerEvent.TIMER, onLimit);
			
			//adds replay button
			replayBtn = new Replay();
			replayBtn.x = stage.stageWidth / 2;
			replayBtn.y = stage.stageHeight / 2;
			addChild(replayBtn);
			replayBtn.addEventListener(MouseEvent.CLICK, onReplay);
			
		}
		
		//returns the user back to main menu screen if they click replay
		public function onReplay(e:MouseEvent):void
		{
			//resets score
			score = 0;
			
			sc3.stop(); //stops lose music
			onlyMusic = false; //changes onlyMusic to false so main menu music can start again
			removeChild(replayBtn); //removes replay button
			replayBtn.removeEventListener(MouseEvent.CLICK, onReplay); //removes event listener for replay button
			
			gotoAndStop(1); //goes to main menu
			onlyOnce = true; //resets onlyOnce back to true so player can lose again
			levelType = 0; //resets level type
		}
		
		public function onKeyD(e:KeyboardEvent):void
		{
			//checks to see it user pressed left, right, up, or down button
			//and applies snake direction accordingly
			//NOTE: we got this idea at https://srdragos.wordpress.com/2013/01/25/build-a-classic-snake-game-in-actionscript-2-0/
			//but we didn't completely copy it 
			if (e.keyCode == Keyboard.LEFT)
			{
				snakeDirection = "left";
			}
			else if (e.keyCode == Keyboard.RIGHT)
			{
				snakeDirection = "right";
			}
			else if (e.keyCode == Keyboard.UP) 
			{
				snakeDirection = "up";
			}
			else if (e.keyCode == Keyboard.DOWN) 
			{
				snakeDirection = "down";
			}
		}
		
		public function onKeyU(e:KeyboardEvent):void 
		{
			//resets the snake direction when player is not touching
			//left, right, up, or down buttons anymore
			if (e.keyCode == Keyboard.LEFT) 
			{
				snakeDirection = "";
			}
			else if (e.keyCode == Keyboard.RIGHT) 
			{
  				snakeDirection = "";
			}
			else if (e.keyCode == Keyboard.UP) 
			{
				snakeDirection = "";
			}
			else if (e.keyCode == Keyboard.DOWN)
			{
				snakeDirection = "";
			}
		}
		
		//this functions adds an enemy to the stage
		public function onEnemyTick(e:TimerEvent):void
		{
			//checks to see if the player doesn't have the noenemy powerup and adds an enemy on stage and to the array
			if (snakeHasNoEnemy == true)
			{
				trace("You have no enemy powerup!");
			}
			else if (snakeHasNoEnemy == false)
			{
				enemySound = new EnemySound;
				sc4 = enemySound.play(); //plays enemy sound
				enemyType = Math.ceil(Math.random()*4); //generates random num from one to four
				//depending on that numbers adds an enemy ot left, right, top, or bottom of stage
				if (enemyType == 1)
				{
					//top
					enemy1 = new Enemy1();
					enemy1.x = Math.random()*(stage.stageWidth - 200);
					enemy1.y = 0;
					addChild(enemy1);
					enemyArray.push(enemy1);
				}
				else if (enemyType == 4)
				{
					//bottom
					enemy4 = new Enemy4();
					enemy4.x = Math.random()*(stage.stageWidth - 200);
					enemy4.y = stage.height;
					addChild(enemy4);
					enemyArray.push(enemy4);
				}
				else if (enemyType == 3)
				{
					//left
					enemy3 = new Enemy3();
					enemy3.x = 0;
					enemy3.y = Math.random()*(stage.stageHeight - 200);
					addChild(enemy3);
					enemyArray.push(enemy3);
				}
				else if (enemyType == 2)
				{
					//right
					enemy2 = new Enemy2();
					enemy2.x = stage.width;
					enemy2.y = Math.random()*(stage.stageHeight - 200);
					addChild(enemy2);
					enemyArray.push(enemy2);
				}
			}
		}
		
		//this function adds a powerup to the stage (only one powerup at a time)
		public function onPowerup(e:TimerEvent):void
		{
			//checks to see if there is a powerup already on stage or in use
			if (noEnemy != null|| invincible != null || foodMultiplier != null || moreFood != null || slow != null || powerupLengthTimer.running || maxBullet != null)
			{
				trace("There is already a powerup, or there is a power up in use");
			}
			else //otherwises adds powerup on stage
			{
				getPowerupLimit.start(); //starts powerup limit timer
				powerup = Math.ceil(Math.random()*6); //generates random number between 1 - 6, and depending on the number
				//adds the appropriate powerup to the stage
				if (powerup == 1)
				{
					noEnemy = new NoEnemy();
					noEnemy.x = Math.random()*(stage.stageWidth - 200);
					noEnemy.y = Math.random()*(stage.stageHeight - 200);
					addChild(noEnemy);
				}
				else if (powerup == 2)
				{
					invincible = new Invincible();
					invincible.x = Math.random()*(stage.stageWidth - 200);
					invincible.y = Math.random()*(stage.stageHeight - 200);
					addChild(invincible);
				}
				else if (powerup == 3)
				{
					foodMultiplier = new Multiply();
					foodMultiplier.x = Math.random()*(stage.stageWidth - 200);
					foodMultiplier.y = Math.random()*(stage.stageHeight - 200);
					addChild(foodMultiplier);
				}
				else if (powerup == 4)
				{
					moreFood = new MoreFood();
					moreFood.x = Math.random()*(stage.stageWidth - 200);
					moreFood.y = Math.random()*(stage.stageHeight - 200);
					addChild(moreFood);
				}
				else if (powerup == 5)
				{
					maxBullet = new MaxBullet();
					maxBullet.x = Math.random()*(stage.stageWidth - 200);
					maxBullet.y = Math.random()*(stage.stageHeight - 200);
					addChild(maxBullet);
				}
				else
				{
					slow = new Slow();
					slow.x = Math.random()*(stage.stageWidth - 200);
					slow.y = Math.random()*(stage.stageHeight - 200);
					addChild(slow);
				}
			}
		}
		
		//this function stops the powerup after a certain time
		public function onPowerupLength(e:TimerEvent):void
		{
			
			powerupLengthTimer.reset(); //resets the powerup length timer because the powerup ran out
			
			//removes the powerup symbol at top of stage
			if (noEnemySymbol != null && snakeHasNoEnemy == true)
			{
				removeChild(noEnemySymbol);
			}
			else if (invincibleSymbol != null && snakeHasInvincible == true)
			{
				removeChild(invincibleSymbol);
			}
			else if (foodMultiplierSymbol != null && snakeHasMultiply == true)
			{
				removeChild(foodMultiplierSymbol);
			}
			else if (moreFoodSymbol != null && snakeHasMoreFood == true)
			{
				removeChild(moreFoodSymbol);
			}
			else if (slowSymbol != null && snakeHasSlow == true)
			{
				removeChild(slowSymbol);
			}
			else if (maxBulletSymbol != null && snakeHasMaxBullet == true)
			{
				removeChild(maxBulletSymbol);
			}
			
			//resets all powerup conditional variables
			snakeHasNoEnemy = false;
			snakeHasInvincible = false;
			snakeHasMultiply = false;
			snakeHasMoreFood = false;
			snakeHasSlow = false;
			snakeHasMaxBullet = false;
			
			
			//plays background music again depending on level
			if (levelType == 1)
			{
				music1 = new Music1();
				sc.stop();
				sc = music1.play(0, 9999);
			}
			else if (levelType == 2)
			{
				music2 = new Music2();
				sc.stop();
				sc = music2.play(0, 9999);
			}
			else if (levelType == 3)
			{
				music3 = new Music3();
				sc.stop();
				sc = music3.play(0, 9999);
			}
		}
		
		
		public function gameLoop(e:Event):void 
		{
			//checks to see if more food powerup is over and 
			//removes food if there is more than one food on screen 
			if (snakeHasMoreFood == false && foodArray.length >= 2)
			{
				for (var r1:int = foodArray.length - 1; r1 >= 0; r1--)
				{
					if (foodArray[r1] != null)
					{
						removeChild(foodArray[r1]);
						foodArray.splice(r1, 1);
						break;
					}
				}
				
			}
			
			//setting direction of velocity depending on direction
			//also the player can't go backwards if the velocity is the other direction
			if (snakeHasSlow == true) //checks to see if player has slow powerup and decreases velocity
			//otherwise velocity is normal
			{
				if (snakeDirection == "left" && vx != 0.5)  
				{
					vx = -0.5; //moves left
					vy = 0;
				}
				else if (snakeDirection == "right" && vx != -0.5) 
				{
					vx = 0.5; //moves right
					vy = 0;
				}
				else if (snakeDirection == "up" && vy != 0.5) 
				{
					vx = 0;
					vy = -0.5; //moves up
				}
				else if (snakeDirection == "down" && vy != -0.5) 
				{
					vx = 0;
					vy = 0.5; //moves down
				}
			}
			else
			{
				if (snakeDirection == "left" && vx != 1) 
				{
					vx = -1;
					vy = 0;
				}
				else if (snakeDirection == "right" && vx != -1) 
				{
					vx = 1;
					vy = 0;
				}
				else if (snakeDirection == "up" && vy != 1) 
				{
					vx = 0;
					vy = -1;
				}
				else if (snakeDirection == "down" && vy != -1) 
				{
					vx = 0;
					vy = 1;
				}
			}
	
			//checks to see if player has invincible powerup 
			//and if they do, stops the head from moving if it hit the walls
			if (snakeHasInvincible == true)
			{
				if (snake[0] != null)
				{
					if (snake[0].x < 0)
					{
						snake[0].x = 0;
					}
					if (snake[0].x > stage.stageWidth)
					{
						snake[0].x = stage.stageWidth;
					}
					if (snake[0].y < 0)
					{
						snake[0].y = 0;
					}
					if (snake[0].y > stage.stageHeight)
					{
						snake[0].y = stage.stageHeight;
					}
					
				}
			}
			else //otherwise resets the game
			{
				//collison (TOUCHING OUTSKIRTS OF THE STAGE) with stage
				if (snake[0] != null)
				{
					if (snake[0].x < 0 || snake[0].x > stage.stageWidth || snake[0].y < 0|| snake[0].y > stage.stageHeight)
					{
						if (onlyOnce == true) 
						{
							reset();
							onlyOnce = false; //onlyOnce is set to false to avoid reset function to keep running
						}
					}
					
				}
				
				//checks to see if snake hit body by checking if a body part x and y values is equal to the head
				if (snake.length > 3)
				{
					for (var g:int = snake.length - 1; g > 1; g--)
					{
						if (snake[g] != null && snake[0].x == snake[g].x && snake[0].y == snake[g].y)
						{
							if (onlyOnce == true)
							{
								reset();
								onlyOnce = false;
							} //end if
							
						} //end if 
					}// end for
				} //end if
			}//end else
					
					
			//MOVING THE BODY OF THE SNAKE 
			//by looping through the array
			//and making each snake part go in 
			//the position of the last snake part in the array
			//NOTE: we got this idea from http://stackoverflow.com/questions/9916946/snake-segments-to-follow-a-head-in-a-snake-game
			//and https://srdragos.wordpress.com/2013/01/25/build-a-classic-snake-game-in-actionscript-2-0/
			for (var a:int = snake.length - 1; a > 0; a--)
			{
				if (snake[a] != snake[0] && snakeHasInvincible == false) //checks to see if snake doesn't have invincible powerup
				{ 
					snake[a].x = snake[a - 1].x;
					snake[a].y = snake[a - 1].y;
				}
				else if (snake[a] != snake[0] && snakeHasInvincible == true)
				{
					//if the snake head is touching boundaries with invincible then we don't move body
					if (snake[0].x < 0 || snake[0].x > stage.stageWidth || snake[0].y < 0 || snake[0].y > stage.stageHeight)
					{
						trace("Can't move body");
					}
					else //otherwise just keeps moving body parts
					{
						snake[a].x = snake[a - 1].x;
						snake[a].y = snake[a - 1].y;
					}
				}
			}//end for
				
			//moving snake's head 
			//by adding the velocity multiplied by the speed
			//to its x and y position
			head.x += vx * speed;
			head.y += vy * speed;
	
			//checks all snake parts and depending on the x and y position of the next or previous
			//parts, we can determine what way the snake part is supposed to be going 
			//and change the sprites of the snake part according to the correct directions
			//NOTE: we didn't figure this one out because it's too complicated
			//we got this at and the sprites at http://rembound.com/articles/creating-a-snake-game-tutorial-with-html5
			for (var i:int = 0; i < snake.length; i++)
			{
				if (snake[i] == snake[0]) //HEAD
				{
					nextSeg = snake[i + 1];
					if (snake[i].y < nextSeg.y)
					{
						//up
						snake[i].gotoAndStop(1);
					}
					else if (snake[i].x > nextSeg.x)
					{
						//right
						snake[i].gotoAndStop(2);
					}
					else if (snake[i].y > nextSeg.y)
					{
						//down
						snake[i].gotoAndStop(3);
					}
					else if (snake[i].x < nextSeg.x)
					{
						//left
						snake[i].gotoAndStop(4);
					}
				}
				else if (snake[i] == snake[snake.length - 1]) //TAIL
				{
					prevSeg = snake[i - 1];
					if (prevSeg.y < snake[i].y)
					{
						//up
						snake[i].gotoAndStop(5);
					}
					else if (prevSeg.x > snake[i].x)
					{
						//right
						snake[i].gotoAndStop(6);
					}
					else if (prevSeg.y > snake[i].y)
					{
						//down
						snake[i].gotoAndStop(7);
					}
					else if (prevSeg.x < snake[i].x)
					{
						//left
						snake[i].gotoAndStop(8);
					}
				}
				else //BODY PART
				{
					nextSeg = snake[i + 1];
					prevSeg = snake[i - 1];
					if (prevSeg.x < snake[i].x && nextSeg.x > snake[i].x || nextSeg.x < snake[i].x && prevSeg.x > snake[i].x) 
					{
						//horizontal left-right
						snake[i].gotoAndStop(9);
					} 
					else if (prevSeg.x < snake[i].x && nextSeg.y > snake[i].y || nextSeg.x < snake[i].x && prevSeg.y > snake[i].y)
					{
						//angle left-down
						snake[i].gotoAndStop(10);
					
					} 
					else if (prevSeg.y < snake[i].y && nextSeg.y > snake[i].y || nextSeg.y < snake[i].y && prevSeg.y > snake[i].y) 
					{
						//vertical up-down
						snake[i].gotoAndStop(11);
					
					} 
					else if (prevSeg.y < snake[i].y && nextSeg.x < snake[i].x || nextSeg.y < snake[i].y && prevSeg.x < snake[i].x) 
					{
						//angle top-left
						snake[i].gotoAndStop(12);
				   
					} 
					else if (prevSeg.x > snake[i].x && nextSeg.y < snake[i].y || nextSeg.x > snake[i].x && prevSeg.y < snake[i].y) 
					{
						//angle right-up
						snake[i].gotoAndStop(13);
					
					} 
					else if (prevSeg.y > snake[i].y && nextSeg.x > snake[i].x || nextSeg.y > snake[i].y && prevSeg.x > snake[i].x) 
					{
						//angle down-right
						snake[i].gotoAndStop(14);
					
					}
				}
				
			}
			
		
			//collision with food
			for (var q:int = foodArray.length - 1; q >= 0; q--)
			{
				if (foodArray[q] != null && snake[0] != null && snake[0].hitTestObject(foodArray[q]))
				{
					if (snakeHasMultiply == false) //checks to see if snake does not have multiply powerup
					//and justs adds one body part and increases score by 2
					{
						if (foodCount < 2) //checks to see if snake has moreFood powerup and increases foodCount by one
						//if less than two
						{
							foodCount++;
						}
						growSound = new GrowSound(); 
						sc2 = growSound.play(0, 1, trans); //plays grow sound
						score += 2; //increase the score by two
						removeChild(foodArray[q]); //we remove the food from the stage and array
						foodArray.splice(q, 1); 
						addFood(); //we call the addFood function again to add more food
						bodyPart = new SnakePart(); //add a body part
						bodyPart.x = snake[snake.length - 2].x; //body part position is equal to the last body part position before tail
						bodyPart.y = snake[snake.length - 2].y;
						addChild(bodyPart);
						snake.push(bodyPart);
						bodyPart.gotoAndStop(11); //default body part position
					}
					else if (snakeHasMultiply == true) //otherwise adds two body parts and increase score by 4
					{
						growSound = new GrowSound();
						sc2 = growSound.play(0, 1, trans);
						score += 4; //increase the score by four
						removeChild(foodArray[q]); //we remove the food from the stage and array
						foodArray.splice(q, 1);
						addFood(); //we call the add food function again to add more food
					
						//adds two body parts
						bodyPart = new SnakePart();
						bodyPart.x = snake[snake.length - 2].x;
						bodyPart.y = snake[snake.length - 2].y;
						addChild(bodyPart);
						snake.push(bodyPart);
						bodyPart.gotoAndStop(11);
				
						bodyPart = new SnakePart();
						bodyPart.x = snake[snake.length - 2].x;
						bodyPart.y = snake[snake.length - 2].y;
						addChild(bodyPart);
						snake.push(bodyPart);
						bodyPart.gotoAndStop(11);
						
					}
				}
			}
			
			//DISPLAYING SCORE ON SCREEN 
			if (txtScore != null)
			{
				txtScore.text = score.toString(); //converting score to string and displaying it 
			}  
	
			//checks to see if the powerup isn't null and if the snake hit a powerup
			//we remove the powerup, set the respective powerup conditional variable to true
			//start the powerup length timer, and reset the getpoweruplimit timer . as well we add the powerup symbol to the top of the screen
			//next to the pause button
			if (snake[0] != null && noEnemy != null && snake[0].hitTestObject(noEnemy))
			{
				getPowerupLimit.reset(); //resets powerup limit timer
				powerupSound = new PowerupSound(); 
				sc1 = powerupSound.play(); //plays powerup sound effect
				snakeHasNoEnemy = true; //sets conditional variable to true
				powerupLengthTimer.start();
				removeChild(noEnemy);
				noEnemy = null;
				
				noEnemySymbol = new NoEnemySymbol(); //adds powerup symbol
				noEnemySymbol.x = stage.stageWidth - 70;
				noEnemySymbol.y = 25;
				addChild(noEnemySymbol);
				
				powerupMusic = new PowerupMusic(); //plays powerup music and stops background music
				sc.stop();
				sc = powerupMusic.play(0, 9999);
				
				//removes all enemies
				for (var k:int = enemyArray.length - 1; k >= 0; k--)
				{
					if (enemyArray[k] != null)
					{
						removeChild(enemyArray[k]);
						enemyArray[k] = null;
						enemyArray.splice(k, 1);
					}
				
				}
			}
			if (snake[0] != null && invincible != null && snake[0].hitTestObject(invincible))
			{
				getPowerupLimit.reset();
				powerupSound = new PowerupSound();
				sc1 = powerupSound.play();
				snakeHasInvincible = true;
				powerupLengthTimer.start();
				removeChild(invincible);
				invincible = null;
				invincibleSymbol = new InvincibleSymbol();
				invincibleSymbol.x = stage.stageWidth - 70;
				invincibleSymbol.y = 25;
				addChild(invincibleSymbol);
				
				powerupMusic = new PowerupMusic();
				sc.stop();
				sc = powerupMusic.play(0, 9999);
			}
			if (snake[0] != null && foodMultiplier != null && snake[0].hitTestObject(foodMultiplier))
			{
				getPowerupLimit.reset();
				powerupSound = new PowerupSound();
				sc1 = powerupSound.play();
				snakeHasMultiply = true;
				powerupLengthTimer.start();
				removeChild(foodMultiplier);
				foodMultiplier = null;
				foodMultiplierSymbol = new MultiplySymbol();
				foodMultiplierSymbol.x = stage.stageWidth - 70;
				foodMultiplierSymbol.y = 25;
				addChild(foodMultiplierSymbol);
				
				powerupMusic = new PowerupMusic();
				sc.stop();
				sc = powerupMusic.play(0, 9999);
			}
			if (snake[0] != null && moreFood != null && snake[0].hitTestObject(moreFood))
			{
				getPowerupLimit.reset();
				powerupSound = new PowerupSound();
				sc1 = powerupSound.play();
				snakeHasMoreFood = true;
				powerupLengthTimer.start();
				removeChild(moreFood);
				moreFood = null;
				moreFoodSymbol = new MoreFoodSymbol();
				moreFoodSymbol.x = stage.stageWidth - 70;
				moreFoodSymbol.y = 25;
				addChild(moreFoodSymbol);
				
				powerupMusic = new PowerupMusic();
				sc.stop();
				sc = powerupMusic.play(0, 9999);
			}
			if (snake[0] != null && slow != null && snake[0].hitTestObject(slow))
			{
				getPowerupLimit.reset();
				powerupSound = new PowerupSound();
				sc1 = powerupSound.play();
				snakeHasSlow = true;
				powerupLengthTimer.start();
				removeChild(slow);
				slow = null;
				slowSymbol = new SlowSymbol();
				slowSymbol.x = stage.stageWidth - 70;
				slowSymbol.y = 25;
				addChild(slowSymbol);
				
				powerupMusic = new PowerupMusic();
				sc.stop();
				sc = powerupMusic.play(0, 9999);
			}
			if (snake[0] != null && maxBullet != null && snake[0].hitTestObject(maxBullet))
			{
				getPowerupLimit.reset();
				powerupSound = new PowerupSound();
				sc1 = powerupSound.play();
				snakeHasMaxBullet = true;
				powerupLengthTimer.start();
				removeChild(maxBullet);
				maxBullet = null;
				maxBulletSymbol = new MaxBulletSymbol();
				maxBulletSymbol.x = stage.stageWidth - 70;
				maxBulletSymbol.y = 25;
				addChild(maxBulletSymbol);
				
				powerupMusic = new PowerupMusic();
				sc.stop();
				sc = powerupMusic.play(0, 9999);
			}
			
			//checks to see if food is on top on another food and removes it
			//and add another food
			for (var b1:int = 0; b1 < foodArray.length; b1++)
			{
				for (var b2:int = 0; b2 < foodArray.length; b2++)
				{
					if (foodArray[b1] != null && foodArray[b2] != null && foodArray[b1].hitTestObject(foodArray[b2]) && foodArray[b1] != foodArray[b2])
					{
						removeChild(foodArray[b1]);
						foodArray.splice(b1, 1);
						
						food = new Food();
						food.x = 50 + Math.random()*(stage.stageWidth - 200);
						food.y = 50 + Math.random()*(stage.stageHeight - 200);
						addChild(food);
						foodArray.push(food);
						
					}
				}
			}
			
			
			//moves the bullets
			for (var p:int = 0; p < bulletArray.length; p++)
			{
				//checks to see what direction bullet came from
				//by checking type of class and moves the bullet in 
				//that direction accordingly
				//NOTE: we got information on how to check what type of class an object is 
				//from http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7f8a.html
				if (bulletArray[p] is Bullet1) //up
				{
					//bullet moves more faster depending on levelType
					if (levelType == 1)
					{
						bulletArray[p].y -= 20;
					}
					else if (levelType == 2)
					{
						bulletArray[p].y -= 25;
					}
					else if (levelType == 3)
					{
						bulletArray[p].y -= 30;
					}
				}
				else if (bulletArray[p] is Bullet2) //right
				{
					if (levelType == 1)
					{
						bulletArray[p].x += 20;
					}
					else if (levelType == 2)
					{
						bulletArray[p].x += 25;
					}
					else if (levelType == 3)
					{
						bulletArray[p].x += 30;
					}
				}
				else if (bulletArray[p] is Bullet3) //down
				{
					if (levelType == 1)
					{
						bulletArray[p].y += 20;
					}
					else if (levelType == 2)
					{
						bulletArray[p].y += 25;
					}
					else if (levelType == 3)
					{
						bulletArray[p].y += 30;
					}
				}
				else if (bulletArray[p] is Bullet4) //left
				{
					if (levelType == 1)
					{
						bulletArray[p].x -= 20;
					}
					else if (levelType == 2)
					{
						bulletArray[p].x -= 25;
					}
					else if (levelType == 3)
					{
						bulletArray[p].x -= 30;
					}
				}
				
				//checks if bullet hit boundary of stage and removes it 
				if (bulletArray[p] != null && bulletArray[p].x < 0 || bulletArray[p].x > stage.stageWidth || bulletArray[p].y < 0 || bulletArray[p].y > stage.stageHeight)
				{
					removeChild(bulletArray[p]);
					bulletArray.splice(p, 1);
				}
				
				//checks to see if bullet hit a enemy 
				for (var r:int = 0; r < enemyArray.length; r++)
				{
					if (bulletArray[p] != null && enemyArray[r] != null && bulletArray[p].hitTestObject(enemyArray[r]))
					{
						hitSound = new HitSound(); 
						sc8 = hitSound.play(); //plays hit sound
						score += 5; //icrease score by 5
						removeChild(bulletArray[p]); //removes bullet from stage and array
						bulletArray.splice(p, 1);
						removeChild(enemyArray[r]); //removes enemy from stage and array
						enemyArray.splice(r, 1);
					}
				}
			}
			
			//moves enemies 
			for (var u:int; u < enemyArray.length; u++)
			{
				//checks to see what direction enemy is moving depending on class
				//and moves enemy across screen depending on the ey or ex value set in the constructor 
				//depending on levelType
				if (enemyArray[u] is Enemy1)
				{
					enemyArray[u].y += ey;
				}
				else if (enemyArray[u] is Enemy2)
				{
					enemyArray[u].x -= ex;
				}
				else if (enemyArray[u] is Enemy3)
				{
					enemyArray[u].x += ex;
				}
				else if (enemyArray[u] is Enemy4)
				{
					enemyArray[u].y -= ey;
				}

				//nested loop for snake
				for (var t:int = 0; t < snake.length; t++)
				{
					if (enemyArray[u] != null)
					{
						//removes enemy if it goes off stage
						if (enemyArray[u].x < 0 || enemyArray[u].x > stage.stageWidth ||enemyArray[u].y < 0|| enemyArray[u].y > stage.stageHeight)
						{
							removeChild(enemyArray[u]);
							enemyArray.splice(u, 1);
						}//end if
					}//end if
					
					//checks to see if enemy hit snake (player)
					if (enemyArray[u] != null && snake[t] != null && enemyArray[u].hitTestObject(snake[t]))
					{
						if (snakeHasInvincible == false) //if the snake doesn't have invincible
						{
							if (snake.length > 3) //checks to see if snake length is greater than 3
							{ 
								if (snake[t].currentFrame == 1 || snake[t].currentFrame == 2 || snake[t].currentFrame == 3 || snake[t].currentFrame == 4) //HEAD
								{
									if (onlyOnce == true)
									{
										//resets game if enemy touches snake head
										reset();
										onlyOnce = false;
									} //end if for reset
								}//end if for head check
								else if (snake[t].currentFrame == 5 || snake[t].currentFrame == 6 || snake[t].currentFrame == 7 || snake[t].currentFrame == 8) //TAIL
								{
									prevSeg2 = snake[t - 1]; //checks previous segment
									
									//change the previous segment to the new tail 
									//by changing sprites and remove hitted tail
									if (snake[t - 2].y < prevSeg2.y)
									{
										//up
										prevSeg2.gotoAndStop(5);
									}
									else if (snake[t - 2].x > prevSeg2.x)
									{
										//right
										prevSeg2.gotoAndStop(6);
									}
									else if (snake[t - 2].y > prevSeg2.y)
									{
										//down
										prevSeg2.gotoAndStop(7);
									}
									else if (snake[t - 2].x < prevSeg2.x)
									{
										//left
										prevSeg2.gotoAndStop(8);
									}
									
									shrinkSound = new ShrinkSound();
									sc6 = shrinkSound.play(); //plays shrink sound
									removeChild(snake[t]); //removes tail from stage and array
									snake.splice(t, 1);
									score -= 2; //score is deducted by 2
									
								}//end else if for tail check
								else //BODY PART
								{
									//removes body part if enemy touches snake body part
									shrinkSound = new ShrinkSound();
									sc6 = shrinkSound.play(); //plays shrink sound
									removeChild(snake[t]); //removes body part from stage and array
									snake.splice(t, 1);
									score -= 2; //decreases score
								}//end else for body check
							}//end if for snake length > 3
							else  //if snake length is less than 3, resets game because no more body parts to remove
							{
								if (onlyOnce == true)
								{
									reset();
									onlyOnce = false;
								}//end if for reset
							} //end else
						}//end check for invincible
						else //if snake has invincible, removes enemy instead
						{
							hitSound = new HitSound(); 
							sc8 = hitSound.play(); //plays hit sound
							removeChild(enemyArray[u]);
							enemyArray.splice(u, 1);
						}//end else
					} //end if for hit test object
				}//end for snake
				
			}// end for enemy
		
		}//end gameLoop
		
	} //end class
}//end package
