using UnityEngine;
using System.Collections;
using System.Collections.Generic;
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

	private int monsterIdx = 0;
	private Dictionary < int ,  MonsterController > m_monsterMap = new Dictionary<int, MonsterController>();

	// Use this for initialization
	public void CreatePlayer()
	{
		m_player = ServiceLocator< ResourceManager >.Instance.LoadRes (PLAYER_RES_PATH , true );
		m_player.AddComponent< PlayerController > ();
	}

	public void CreateMonster()
	{
		GameObject monster = ServiceLocator< ResourceManager >.Instance.LoadRes (MONSTER_RES_PATH , true );
		MonsterController controller = monster.AddComponent< MonsterController > ();
		controller.Setup (monsterIdx);
		m_monsterMap[ monsterIdx ] =  controller ;
		monsterIdx ++;
	}

	// Update is called once per frame
	void Update () {
	
	}
}
