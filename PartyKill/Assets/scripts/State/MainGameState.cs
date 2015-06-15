using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;

public class MainGameState : GameState {
	long PLAY_STATE = 0;

	public MainGameState( StateManager p_stateMgr ) : base( p_stateMgr )
	{
		ZuDebug.Log ("####### MainGameState start #########");
		ServiceLocator< CharacterManager >.Instance.CreatePlayer ();

		PLAY_STATE = TaskManager.CreateState ();

		TaskManager.AddTask (new PlayerTask (), PLAY_STATE);
		TaskManager.AddTask (new MonsterTask (), PLAY_STATE);
	}

	#region implement of GameState
	public override void Init()
	{
		TaskManager.ChangeState (PLAY_STATE);
	}

	public override void Update(float deltaTime)
	{
		base.Update (deltaTime);
	}

	#endregion
}
