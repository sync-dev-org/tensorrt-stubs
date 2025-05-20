import tensorrt as trt
import tensorrt_bindings


def test_tensorrt_import():
    """Test that tensorrt can be imported."""
    assert trt is not None
    assert trt.Logger is not None
    assert trt.Builder is not None


def test_tensorrt_bindings_import():
    """Test that tensorrt_bindings can be imported."""
    assert tensorrt_bindings is not None
    assert tensorrt_bindings.tensorrt is not None
