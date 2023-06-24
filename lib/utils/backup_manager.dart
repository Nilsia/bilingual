class BackupManager {
  Future<int> Function(dynamic)? restorer;
  dynamic args;

  BackupManager({this.restorer, this.args});

  void addBackup(Future<int> Function(dynamic) restorer, dynamic args) {
    this.restorer = restorer;
    this.args = args;
  }

  Future<int> executeBackup() async {
    if (restorer != null && args != null) {
      return restorer!(args);
    } else {
      return -1;
    }
  }

  void clear() {
    args = null;
    restorer = null;
  }
}
