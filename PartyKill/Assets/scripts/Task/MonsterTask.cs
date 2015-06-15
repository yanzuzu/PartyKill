using UnityEngine;
using System.Collections;
using ZuEngine.StateManagement;
using ZuEngine.Manager;
using ZuEngine;

public class MonsterTask : Task {
	private const int SPAWN_MONSTER_TIME = 10;
	private float m_timeCount = 0;

	public MonsterTask()
	{

	}

	#region implement of task
	public override void Pause()
	{
	}
	
	public override void Resume()
	{
	}
	
	public override void Show(bool p_show)
	{
		
	}
	
	public override void Update(float p_deltaTime)
	{
//		m_timeCount += p_deltaTime;
//		if( m_timeCount >= SPAWN_MONSTER_TIME )
//		{
//			ServiceLocator< CharacterManager >.Instance.CreateMonster();
//			m_timeCount = 0;
//		}
		if( Input.GetKeyDown( KeyCode.M ))
		{
			ServiceLocator< CharacterManager >.Instance.CreateMonster();
		}
	}
	
	#endregion
}
