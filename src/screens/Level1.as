package screens 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import com.friendsofed.vector.*;
	import com.friendsofed.utils.TextBox;
	import flash.display.Graphics;
	import flash.geom.Point;
	import mx.core.SoundAsset;
	import gameObjects.*;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.*;
	import utils.*;

	public class Level1 extends Level
	{
		protected var enemyHits:int;
		
		public function Level1() 
		{
			super();

		}

		override protected function OnEnterFrame(e:Event):void 
		{
			//we override the enterframe handler keeping the previous one and adding some other behaviour
			super.OnEnterFrame(e);
			
			if (enemyHits == Constants.N_PROJECTILES) 
			{
				super.EndLevel();
				return;
			}
		}
		
		override protected function onAddedToStage(e:Event):void 
		{
			super.onAddedToStage(e);
			
			//we positionate and draw the background
			backgound = new Image(Assets.getTexture("Level1Backgorund"));
			backgound.alignPivot();
			this.addChildAt(backgound, stage.numChildren - 1);
			
			backgound.x = stage.stageWidth / 2;
			backgound.y = stage.stageHeight / 2;
			
			backgound.scale = 1.4;
		}
		
		override protected function MoveEntities(enemigos:Vector.<Enemy>,bullets:Vector.<Bullet>):void 
		{
			//if there are balls
			if (enemigos.length > 0)
			{
				for (var i:int = enemigos.length - 1; i >= 0 ; i--)
				{
					//check if theres collision with the stage boundaries
					if (physics.TestBoundaries(enemigos[i])) 
					{
						//if there is collision calculate the bounce vector
						physics.bounceWithBoundarie(enemigos[i]);
					}
					
					 //check for every other ball but without comparing them twice // j < i
					for (var j:int = 0; j < i; j++)
					{
						//check again against the boundaries
						if (physics.TestBoundaries(enemigos[j])) 
						{
							physics.bounceWithBoundarie(enemigos[j]);
						}
						
						if (physics.AreBallsColliding(enemigos[i], enemigos[j]))
						{
							physics.BounceBetweenBalls(enemigos[i], enemigos[j]);
						}		
					}
					
					//check if there's collision between bullets and enemies
					for (var k:int = bullets.length - 1; k >= 0; k--) 
					{
						if (physics.AreBallsColliding(bullets[k],enemigos[i]))
						{
							//we add 300 to the score each time we hit an enemy
							score.AddScore(300);
							
							//remove the enemy
							removeChild(enemigos[i].removeChild(enemigos[i].m_Image));
							enemigos.removeAt(i);
							
							//remove the bullet
							removeChild(bullets[k].removeChild(bullets[k].m_Image));
							bullets.removeAt(k);
							
							//we add a hit to our enemyHits count
							enemyHits += 1;
							

							//this return is preventing the access of an invalid i index
							return;
						}
					}
					
					enemigos[i].update();
					enemigos[i].x = enemigos[i].posX;
					enemigos[i].y = enemigos[i].posY;	
				}
				
				MoveBullets(bullets);
				super.CheckCollisionWithPlayer(enemigos);
			}
		}
	}

}