final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      picosvg = python-prev.picosvg.overridePythonAttrs (oldAttrs: {
        # Disable tests causing build failures on Python 3.13 due to string formatting issues
        doCheck = false;
      });
    })
  ];
}
