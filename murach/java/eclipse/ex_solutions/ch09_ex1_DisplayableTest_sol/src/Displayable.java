public interface Displayable {
    default String getDisplayText() {
        return toString();
    }
}
