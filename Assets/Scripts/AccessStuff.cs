using UnityEngine;

public class AccessStuff : MonoBehaviour
{
    private Renderer _sineWave;

    private void Start()
    {
        _sineWave = GetComponent<Renderer>();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            _sineWave.material.SetFloat("_Period", Input.mousePosition.x);
            _sineWave.material.SetTextureScale("_MainTex", new Vector2(0f, 0f));
        }
        else if (Input.GetKeyUp(KeyCode.E))
        {
            _sineWave.material.SetFloat("_Period", 0);
            _sineWave.material.SetTextureScale("_MainTex", new Vector2(Time.deltaTime, 0f));
        }
    }
}
