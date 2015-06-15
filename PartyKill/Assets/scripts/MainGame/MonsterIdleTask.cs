using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;
using ZuEngine.Manager;
using ZuEngine.Event;

public class MonsterIdleTask : Task {
	private const int DETECT_RANGE = 5;

	public MonsterIdleTask()
	{
	}

	#region implement of task
	public override void Pause()
	{
	}
	
	public override void Resume()
	{
		MonsterState monsterState = (MonsterState)StateManager.CurrentState;
		MonsterController controller =  monsterState.MonsterController;

	}
	
	public override void Show(bool p_show)
	{

	}
	
	public override void Update(float p_deltaTime)
	{
		// detect is in attack range
		Vector3 playerPos = ServiceLocator< CharacterManager >.Instance.Player.transform.position;
		MonsterState monsterState = (MonsterState)StateManager.CurrentState;
		MonsterController controller =  monsterState.MonsterController;

		float distance = Vector3.Distance (playerPos, controller.gameObject.transform.position);
		if( distance <= DETECT_RANGE )
		{
			ServiceLocator< EventManager >.Instance.SendEvent( EventID.ON_MONSTER_DETECT_PLAYER , controller.MonsterIdx );
		}
	}
	

	#endregion
}
