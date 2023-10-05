// 盾构机项目的代码
public class ShieldMachine : MonoBehaviour {
  [SerializeField] private GameObject _bgObj;
  [SerializeField] private GameObject _introVideo;
  [SerializeField] private GameObject _introBtn;
  [SerializeField] private GameObject _modelBtn;
  [SerializeField] private GameObject _model;

  private bool isShield;

  void Start() {
    _isShield=false;
    Switch(_isShield);
  }

  private void Switch(bool isShield) {
    _bgObj.SetActive(isShield);
    _introVideo.SetActive(isShield);
    _introBtn.SetActive(isShield);
    _modelBtn.SetActive(isShield);
    _model.SetActive(isShield);

  }

  public void OnClick() {
    _isShield=!_isShield;
    Switch(_isShield);
  }
}
