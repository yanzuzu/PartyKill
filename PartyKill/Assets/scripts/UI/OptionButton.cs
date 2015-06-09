using UnityEngine;
using System.Collections;

public class OptionButton : MonoBehaviour {
	[SerializeField]
	private BackPack m_backPack;

	public void OnOptionButtonClick()
	{
		if( m_backPack.gameObject.activeSelf )
		{
			m_backPack.FadeOut();
		}else
		{
			m_backPack.FadeIn();
		}
	}
}
