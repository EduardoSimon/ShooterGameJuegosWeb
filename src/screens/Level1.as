package screens 
{
	import main.Cannon;
	import com.friendsofed.vector.*;
	import com.friendsofed.utils.TextBox;
	import flash.display.Graphics;
	import flash.geom.Point;
	import objects.Ball;
	import objects.Enemy;
	import objects.Bullet;
	import starling.display.Sprite;
	import starling.events.*;

	public class Level1 extends Sprite
	{
				
		public static const N_PROJECTILES:int = 10;
		public static const PLAYER_X:Number = 400;
		public static const PLAYER_Y:Number = 300;
		public static const SCORE_DELTA:Number = 0.2;

		protected var score:Score;
		protected var enemies:Vector.<Enemy>;
		protected var bullets:Vector.<Bullet>; 
		protected var physics:Physics;

		public static var CANNON:Cannon;

		public function Level1() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, OnEnterFrame);

			score = new Score(5000, 10, 10, 100, 30, 2);
			enemies = new Vector.<Enemy>();
			bullets = new Vector.<Bullet>();
			physics = new Physics();
			CANNON = new Cannon();
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			
			drawLevel();
		}
		
		private function OnEnterFrame(e:Event):void 
		{
			score.UpdateScoreWithDelta(SCORE_DELTA);
			MoveEntities(enemies, bullets);
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(stage);
			if (touch)
			{
				if (touch.phase == TouchPhase.BEGAN)
				{
					//calculate the angel which we will use to determine the speed in x and y
					var angle:Number = Math.atan2(touch.globalY - PLAYER_Y, touch.globalX - PLAYER_X);
					
					//push to the vector and add to the display list
					var bullet:Bullet = new Bullet(angle, 10);
					bullet.SetX = PLAYER_X + (Math.cos(angle) * 40);
					bullet.SetY = PLAYER_Y + (Math.sin(angle) * 40);
					bullets.push(bullet);
					addChild(bullet);
				}
			}
		}
				
		private function drawLevel():void
		{
			
			//create and display the enemies
			for (var i:int = 0; i < N_PROJECTILES; i++)
			{
				var randomAngle:Number = Math.random() * (2 * Math.PI);
				
				var temp:Enemy = new Enemy(randomAngle, 5);
				
				temp.SetX = Math.random() * stage.stageWidth - temp.width / 2;
				temp.x = temp.posX;
				temp.SetY = Math.random() * stage.stageHeight - temp.height / 2;
				temp.y = temp.posY;
				
				enemies.push(temp);
				
				addChild(temp);
			}
			
			//show the score
			addChild(score);
			addChild(physics);
			
			//set the cannon in its correct position
			addChild(CANNON);
			CANNON.CenterPlayerToStage();
			CANNON.SetX = PLAYER_X;
			CANNON.SetY = PLAYER_Y;
		}
		
		public function disposeTemporarily():void{
			this.visible = false;
		}
		
		public function initialize():void{
			this.visible = true;
		}
		
		protected function MoveEntities(pelotas:Vector.<Enemy>,bullets:Vector.<Bullet>):void 
		{
			//if there are balls
			if (pelotas.length > 0)
			{
				for (var i:int = pelotas.length - 1; i >= 0 ; i--)
				{
					//check if theres collision with the stage boundaries
					if (physics.TestBoundaries(pelotas[i])) 
					{
						//if there is collision calculate the bounce vector
						physics.bounceWithBoundarie(pelotas[i]);
					}
					
					 //check for every other ball but without comparing them twice // j < i
					for (var j:int = 0; j < i; j++)
					{
						//check again against the boundaries
						if (physics.TestBoundaries(pelotas[j])) 
						{
							physics.bounceWithBoundarie(pelotas[j]);
						}
						
						if (physics.AreBallsColliding(pelotas[i], pelotas[j]))
						{
							physics.BounceBetweenBalls(pelotas[i], pelotas[j]);
						}		
					}
					
					//check if there's collision between bullets and enemies
					for (var k:int = bullets.length - 1; k >= 0; k--) 
					{
						if (physics.AreBallsColliding(bullets[k],pelotas[i]))
						{
							//TODO add score, this should be done on level class
							score.AddScore(300);
							
							//remove the enemy
							removeChild(pelotas[i].removeChild(pelotas[i].m_Image));
							pelotas.removeAt(i);
							
							//reomve the bullet
							removeChild(bullets[k].removeChild(bullets[k].m_Image));
							bullets.removeAt(k);
							
							return;
						}
					}
					
					
					//Test if they collide with the player
					if (physics.AreBallsColliding(pelotas[i], CANNON))
					{
						physics.bounceWithPlayer(pelotas[i],CANNON);
					}
					
					pelotas[i].update();
					pelotas[i].x = pelotas[i].posX;
					pelotas[i].y = pelotas[i].posY;	
				}
				
				MoveBullets(bullets);
			}	
		}
		
		protected function MoveBullets(bullets:Vector.<Bullet>):void
		{
			if (bullets.length > 0) 
			{
				for (var i:int = bullets.length - 1; i >= 0; i-- ) 
				{
					if (!physics.TestBoundaries(bullets[i])) 
					{
						bullets[i].update();
						bullets[i].x = bullets[i].posX;
						bullets[i].y = bullets[i].posY;
					}
					else
					{
						
						removeChild(bullets[i].removeChild(bullets[i].m_Image));
						bullets.removeAt(i);
						
					}
				}
			}
		}
		
	}

}