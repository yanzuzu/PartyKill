using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour {
	const float move_x = 5;

	const string PLAYER_IDLE_ANIN = "Idle";
	const string PLAYER_RUN_ANIN = "Run";

	private SkeletonAnimation m_anim;

	void Start()
	{
		m_anim = GetComponent< SkeletonAnimation > ();
	}

	public void Move( bool isRight )
	{
		float deltaX = isRight ? 1 : -1;
		Vector3 pos = this.gameObject.transform.position;
		pos = new Vector3( pos.x + deltaX * move_x * Time.deltaTime , pos.y , pos.z ) ;
		this.gameObject.transform.position = pos;

//		if( isRight )
//		{
//			transform.localRotation = Quaternion.Euler (0,0,0);
//		}else
//		{
//			transform.localRotation = Quaternion.Euler (0,180,0);
//		}
		m_anim.AnimationName = PLAYER_RUN_ANIN;
	}

	public void SetIdle()
	{
		m_anim.AnimationName = PLAYER_IDLE_ANIN;
	}
}
