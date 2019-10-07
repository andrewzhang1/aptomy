package CACC_2018.week17;

import java.util.Objects;

public class ClassA {
    public int prop;
    public int prop2;

    public ClassA(int prop) {
        this.prop = prop;
    }

    public ClassA(int prop, int prop2) {
        this.prop = prop;
        this.prop2 = prop2;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClassA classA = (ClassA) o;
        return prop == classA.prop;
    }

    @Override
    public int hashCode() {
        return Objects.hash(prop);
    }
}
