{ pkgs }:

let
  rocmPkgs = pkgs.pkgsRocm;
  aiPython = rocmPkgs.python3.withPackages (pythonPackages:
    with pythonPackages; [
      accelerate
      datasets
      einops
      huggingface-hub
      ipykernel
      jupyterlab
      matplotlib
      numpy
      pandas
      peft
      pillow
      pytest
      safetensors
      scikit-learn
      scipy
      sentencepiece
      tensorboard
      tokenizers
      torch
      torchaudio
      torchvision
      tqdm
      transformers
    ]
  );
in
rocmPkgs.mkShell {
  name = "amd-ai";

  packages = [
    aiPython
    rocmPkgs.rocmPackages.amdsmi
    rocmPkgs.rocmPackages.clr
    rocmPkgs.rocmPackages.hipcc
    rocmPkgs.rocmPackages.rocminfo
    rocmPkgs.cmake
    rocmPkgs.git
    rocmPkgs.ninja
    rocmPkgs.pkg-config
  ];

  HIP_PATH = "${rocmPkgs.rocmPackages.clr}";
  ROCM_PATH = "${rocmPkgs.python3Packages.torch.rocmtoolkit_joined}";
  PYTHONNOUSERSITE = "1";

  shellHook = ''
    echo "AMD ROCm AI 開發環境已載入"
    echo "檢查 GPU：rocminfo"
    echo "監控 GPU：amd-smi"
    echo "檢查 PyTorch：python -c 'import torch; print(torch.cuda.is_available(), torch.version.hip)'"
  '';
}
