using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;

public class MonsterAttackTask : Task {

	public MonsterAttackTask()
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
		controller.PlayWalk ();
	}
	
	public override void Show(bool p_show)
	{
		
	}
	
	public override void Update(float p_deltaTime)
	{
		// go to player position
		Vector3 playerPos = ServiceLocator< CharacterManager >.Instance.Player.transform.position;
		MonsterState monsterState = (MonsterState)StateManager.CurrentState;
		MonsterController controller =  monsterState.MonsterController;

		controller.gameObject.transform.position = Vector3.Lerp (controller.gameObject.transform.position, playerPos , p_deltaTime);
	}
	
	#endregion
}
