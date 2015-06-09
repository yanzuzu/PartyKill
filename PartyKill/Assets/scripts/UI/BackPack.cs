using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class BackPack : MonoBehaviour {

	private CanvasGroup m_canvasGroup;
	private bool m_needToFadeOut = false;


	void Start()
	{
		m_canvasGroup = this.gameObject.GetComponent< CanvasGroup > ();
		gameObject.SetActive (false);
	}

	public void FadeIn()
	{
		m_canvasGroup.alpha = 1;
		this.gameObject.SetActive( true );
		this.gameObject.GetComponent< Animator > ().Play ("BackPackFadeIn");
	}

	public void FadeOut()
	{
		m_needToFadeOut = true;
	}
	
	void Update()
	{
		if( m_needToFadeOut )
		{
			m_canvasGroup.alpha -= Time.deltaTime;
			if( m_canvasGroup.alpha <= 0 )
			{
				m_canvasGroup.alpha = 0;
				this.gameObject.SetActive( false );
				m_needToFadeOut = false;
			}
		}
	}
	
}
