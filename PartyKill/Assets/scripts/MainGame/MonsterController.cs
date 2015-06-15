using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;

public class MonsterController : MonoBehaviour {
	private SkeletonAnimation m_anim;
	const string IDLE_ANIM_NAME = "Idle";
	const string WALK_ANIM_NAME = "walk";

	private StateManager m_stateMgr;
	private int m_monsterIdx = 0;
	public int MonsterIdx
	{
		get{ return m_monsterIdx;}
	}
	// Use this for initialization
	public void Setup ( int p_monsterIdx ) 
	{
		m_monsterIdx = p_monsterIdx;
		m_stateMgr = new StateManager ();
		m_stateMgr.ChangeState( new MonsterState(m_stateMgr , this ) );

		m_anim = GetComponent< SkeletonAnimation > ();
		PlayIdle ();
	}
	
	// Update is called once per frame
	void Update () {
		m_stateMgr.Update (Time.deltaTime);
	}

	public void PlayIdle()
	{
		m_anim.state.SetAnimation( 0 ,WALK_ANIM_NAME  , false );
		m_anim.timeScale = 0;
	}

	public void PlayWalk()
	{
		m_anim.state.SetAnimation( 0 ,WALK_ANIM_NAME  , true );
		m_anim.timeScale = 1;
	}

}
