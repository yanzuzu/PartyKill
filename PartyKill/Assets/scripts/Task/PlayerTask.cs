using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ZuEngine;
using ZuEngine.StateManagement;
using ZuEngine.Input;
using ZuEngine.Manager;

public class PlayerTask : Task , IInputListener  {

	private PlayerController m_player;

	public PlayerTask()
	{
		m_player = ServiceLocator< CharacterManager >.Instance.Player.GetComponent< PlayerController >(); 
		Vector3 pos =  m_player.gameObject.transform.position;
		pos = new Vector3 (pos.x, pos.y, 7.8f);
		m_player.gameObject.transform.position = pos;
	}
	
	#region implement of task
	public override void Pause()
	{
		ServiceLocator< InputProcessor >.Instance.RemoveListener (this);
	}

	public override void Resume()
	{
		ServiceLocator< InputProcessor >.Instance.AddListener (this);
	}

	public override void Show(bool p_show)
	{

	}

	public override void Update(float p_deltaTime)
	{

	}

	#endregion

	#region implement of Input
	//called when a touch starts, returning true will eat the input
	public bool OnPress(Vector2 p_position, List<GameObject> p_hitObjects)
	{
		return true;
	}

	// return true if the event is eaten, false to passthrough to other listeners
	public bool OnTap(Vector2 p_position, List<GameObject> p_hitObjects)
	{
		return true;
	}

	//return true to be the owner of the swipe, others will not recieve the moved/released
	public bool OnSwipeStarted(Vector2 p_startPosition, Vector2 p_currentPosition, List<GameObject> p_hitObjects)
	{
		return true;
	}
	
	public void OnSwipeMoved(Vector2 p_startPosition, Vector2 p_currentPosition, List<GameObject> p_hitObjects)
	{
		float deltaX =  p_currentPosition.x  - p_startPosition.x;

		// right move
		m_player.Move( deltaX > 0 );

	}
	
	public void OnSwipeReleased(Vector2 p_startPosition, Vector2 p_endPosition, List<GameObject> p_hitObjects)
	{
		m_player.SetIdle ();
	}

	#endregion
}
