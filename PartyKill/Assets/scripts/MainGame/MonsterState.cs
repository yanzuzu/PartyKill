using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;
using ZuEngine.Event;

public class MonsterState : GameState {
	private long IDLE_STATE;
	private long ATTACK_STATE;
	private long DEAD_STATE;

	private MonsterController m_monsterController;
	public MonsterController MonsterController
	{
		get{ return m_monsterController;}
	}

	// Use this for initialization
	public MonsterState ( StateManager p_stateMgr , MonsterController p_monsterController ) : base( p_stateMgr )
	{
		IDLE_STATE = TaskManager.CreateState ();
		ATTACK_STATE = TaskManager.CreateState ();
		DEAD_STATE = TaskManager.CreateState ();

		m_monsterController = p_monsterController;

		TaskManager.AddTask (new MonsterIdleTask (), IDLE_STATE);
		TaskManager.AddTask (new MonsterAttackTask (), ATTACK_STATE);
		TaskManager.AddTask (new MonsterDeadTask (), DEAD_STATE);

		ListenForEvent (EventID.ON_MONSTER_DETECT_PLAYER, OnDetectPlayer);
	}

	EventResult OnDetectPlayer( string p_eventName , object p_data )
	{
		int monsterIdx =  (int)p_data;
		if( monsterIdx != m_monsterController.MonsterIdx )
		{
			return null;
		}
		TaskManager.ChangeState (ATTACK_STATE);
		return null;
	}

	#region implement of GameState
	public override void Init()
	{
		TaskManager.ChangeState (IDLE_STATE);
	}
	
	public override void Update(float deltaTime)
	{
		base.Update (deltaTime);
	}
	
	#endregion
}
