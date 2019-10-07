

class Wheel( object):
    def __init__( self):
        # stuff specific to Wheel
        pass

class BikeWheel( Wheel):
    def __init__( self):
        Wheel.__init__( self)
        # stuff specific to Bike Wheel

class CarWheel( Wheel):
    def __init__( self):
        Wheel.__init__( self)
        # stuff specific to Car Wheel


class Motor( object):
    def __init__( self):
        # stuff specific to Motor
        pass

class GasMotor( Motor):
    def __init__( self):
        Motor.__init__( self)
        # stuff specific to Gas Motor

class ElecMotor( Motor):
    def __init__( self):
        Motor.__init__( self)
        # stuff specific to Elec Motor


class Bike( object):
    count = 0
    def __init__( self):
        self.wheels = [BikeWheel() for i in range( 2)]
        Bike.count += 1

class Car( object):
    def __init__( self):
        self.wheels = [CarWheel() for i in range( 5)]
        self.motor = GasMotor()


class Washer( object):
    def __init__( self):
        self.motor = ElecMotor()
