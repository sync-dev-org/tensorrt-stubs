#!/usr/bin/env bash

set -euo pipefail

VENV_DIR=".venv"

TRT_VERSIONS=(
    "10.11.0.33"
    #"10.10.0.31"
    #"10.9.0.34"
    #"10.8.0.43"
    #"10.7.0.post1"
)

PY_VERSION="3.12"


# if not uv installed, install it
if ! command -v uv &> /dev/null; then
    echo "uv is not installed, installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed"
fi


for TRT_VERSION in "${TRT_VERSIONS[@]}" ; do
    echo "Building TensorRT Stubs ${TRT_VERSION}"

    if [[ -d ${VENV_DIR} ]]; then
        echo "Virtual environment already exists, removing it..."
        rm -rf ${VENV_DIR}
    fi

    echo "Creating directory structure..."
    rm -rf src
    mkdir -p src

    cp ./template/pyproject.toml pyproject.toml
    sed -i "s/version = \"0.0.0.0\"/version = \"${TRT_VERSION}\"/" ./pyproject.toml
    sed -i "s/tensorrt==0.0.0.0/tensorrt==${TRT_VERSION}/" ./pyproject.toml
    sed -i "s/tensorrt-cu12-bindings==0.0.0.0/tensorrt-cu12-bindings==${TRT_VERSION}/" ./pyproject.toml

    cp -r ./template/tensorrt_stubs src
    sed -i "s/__version__ = \"0.0.0.0\"/__version__ = \"${TRT_VERSION}\"/" ./src/tensorrt_stubs/__init__.py

    echo "Creating virtual environment..."
    uv python pin ${PY_VERSION}
    uv sync --extra dev
    #uv add tensorrt-cu12-bindings

    if [[ "$OSTYPE" == "msys"* ]]; then
        source ${VENV_DIR}/Scripts/activate
    else
        source ${VENV_DIR}/bin/activate
    fi

    python -m pybind11_stubgen tensorrt --ignore-all-errors --output-dir src
    python -m pybind11_stubgen tensorrt_bindings --ignore-all-errors --output-dir src
    uv build

    deactivate

done
