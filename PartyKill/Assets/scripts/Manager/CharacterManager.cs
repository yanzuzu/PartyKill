using UnityEngine;
using System.Collections;
using ZuEngine.Manager;
using ZuEngine;

public class CharacterManager : MonoBehaviour {
	private const string PLAYER_RES_PATH = "Avatar/hero";
	private const string MONSTER_RES_PATH = "Avatar/Goblins"; 

	private GameObject m_player;
	public GameObject Player
	{
		get{ return m_player; }
	}

	private GameObject m_monster;


	// Use this for initialization
	public void CreatePlayer()
	{
		m_player = ServiceLocator< ResourceManager >.Instance.LoadRes (PLAYER_RES_PATH , true );
		m_player.AddComponent< PlayerController > ();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
