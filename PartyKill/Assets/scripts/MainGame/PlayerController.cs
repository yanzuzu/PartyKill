using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour {
	const float move_x = 5;
	const float move_y = 9.8f;

	const string PLAYER_IDLE_ANIN = "Idle";
	const string PLAYER_RUN_ANIN = "Run";
	const string PLAYER_JUMP_ANIN = "Jump";
	const string PLAYER_ATK_ANIN = "Attack";

	private bool m_isJump;
	private bool m_isFalling;
	private string m_currentAnimation = string.Empty;
	private SkeletonAnimation m_anim;

	void Start()
	{
		m_anim = GetComponent< SkeletonAnimation > ();
		m_anim.state.Event += HandleEvent;
		m_anim.state.End += EndEvent;
		SetAnimation (PLAYER_IDLE_ANIN, true);
	}

	void EndEvent (Spine.AnimationState state, int trackIndex ) 
	{
//		ZuDebug.Log ("EndEvent name = " + state );
//		if( PLAYER_ATK_ANIN == state.ToString() )
//		{
//			//SetIdle ();
//		}
	}

	void HandleEvent (Spine.AnimationState state, int trackIndex, Spine.Event e) 
	{
		//ZuDebug.Log ("HandleEvent name = " + e.Data.name );
	}
	public void Move( bool isRight )
	{
		float deltaX = isRight ? 1 : -1;
		Vector3 pos = this.gameObject.transform.position;
		pos = new Vector3( pos.x + deltaX * move_x * Time.deltaTime , pos.y , pos.z ) ;
		this.gameObject.transform.position = pos;

		if( isRight )
		{
			transform.localRotation = Quaternion.Euler (0,0,0);
		}else
		{
			transform.localRotation = Quaternion.Euler (0,180,0);
		}
		SetAnimation (PLAYER_RUN_ANIN, true);
	}

	public void SetIdle()
	{
		SetAnimation ( PLAYER_IDLE_ANIN , true );
	}

	public void Jump()
	{
		SetAnimation ( PLAYER_JUMP_ANIN , false );
		m_isJump = true;
	}

	public void Attak()
	{
		m_anim.state.SetAnimation(0, PLAYER_ATK_ANIN, false );
		m_anim.state.AddAnimation(0, PLAYER_IDLE_ANIN , true, 0);
	}

	private void SetAnimation (string anim, bool loop) {
		if (m_currentAnimation != anim) {
			m_anim.state.SetAnimation(0, anim, loop);
			m_currentAnimation = anim;
		}
	}

	void Update()
	{
		if( m_isJump )
		{
			Vector3 pos = this.gameObject.transform.position;
			pos = new Vector3( pos.x ,  pos.y + move_y*Time.deltaTime , pos.z ) ;
			this.gameObject.transform.position = pos;
			if( pos.y >= 2.5f )
			{
				m_isFalling = true;
				m_isJump = false;
			}
		}else
		{
			if( m_isFalling )
			{
				Vector3 pos = this.gameObject.transform.position;
				pos = new Vector3( pos.x ,  pos.y - move_y*Time.deltaTime , pos.z ) ;
				this.gameObject.transform.position = pos;
				if( pos.y <= 0 )
				{
					m_isFalling = false;
					m_isJump = false;
					SetIdle();
				}
			}
		}

	}
}
