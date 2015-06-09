using UnityEngine;
using System.Collections;
using ZuEngine;
using ZuEngine.StateManagement;
using ZuEngine.Input;

public class Engine : MonoBehaviour {
	StateManager m_stateMgr ;
	InputManager m_inputMgr;
	// Use this for initialization
	void Start () {
		m_stateMgr = new StateManager ();
		m_stateMgr.ChangeState (new MainGameState (m_stateMgr));
		m_inputMgr = new InputManager ();
	}
	
	// Update is called once per frame
	void Update () {
		float deltaTime =  Time.deltaTime;

		m_stateMgr.Update (deltaTime);
		m_inputMgr.Update (deltaTime);
	}
}
