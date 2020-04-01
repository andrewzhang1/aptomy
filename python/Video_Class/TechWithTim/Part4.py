# Part 4: More complicated sample:
# Advanges to do multiple classes
class Student:
    def __init__(self, name, age, grade):
        self.name = name
        self.age = age
        self.grade = grade  # 0 - 100

    def get_grades(self):
         return self.grade


class Course:  # To have the ability to add students to the Course
    def __init__(self, name, max_students):
        self.name = name
        self.max_students = max_students
        self.students = []  # don't yet

    def add_student(self, student):
        if len(self.students) < self.max_students:
            self.students.append(student)
            return True
        return False

    def get_average_grade(self):
        value = 0
        for student in self.students:
            value += student.get_grades()

        return value / len(self.students)

s1 = Student("Tim", 19, 95)
s2 = Student("Andrew", 34, 75)
s3 = Student("Jill", 19, 66)

course = Course("Science", 3)
course.add_student(s1)
course.add_student(s2)
course.add_student(s3)
print(course.add_student(s3))
print(course.students[0].name)
print(course.get_average_grade())