b = 256
q = 2**255 - 19  # 57896044618658097711785492504343953926634992332820282019728792003956564819949
l = 2**252 + 27742317777372353535851937790883648493

def expmod(b, e, m):
    """ b^e mod m """
    if e == 0:
        return 1
    t = expmod(b, e / 2, m)**2 % m
    if e & 1:
        t = (t * b) % m
    return t


def inv(x):
    """ Return multiplicative inverse of x

    Due to Fermat's little theorem, x^(q-2) mod q = x^-1
    """
    return expmod(x, q - 2, q)

d = -121665 * inv(121666)
I = expmod(2, (q - 1) / 4, q)

dq = d % q
print 'd', d, d.bit_length()
print 'd % q', dq, dq.bit_length()
print '2dq',

def xrecover(y):
    """ Return y given x such that (x,y) is on the curve """
    xx = (y * y - 1) * inv(d * y * y + 1)
    x = expmod(xx, (q + 3) / 8, q)
    if (x * x - xx) % q != 0:
        x = (x * I) % q
    if x % 2 != 0:
        x = q - x
    return x

By = 4 * inv(5)
Bx = xrecover(By)
B = [Bx % q, By % q]

def edwards(P, Q):
    """ Point addition P + Q = -R """
    x1 = P[0]
    y1 = P[1]
    x2 = Q[0]
    y2 = Q[1]
    x3 = (x1 * y2 + x2 * y1) * inv(1 + d * x1 * x2 * y1 * y2)
    y3 = (y1 * y2 + x1 * x2) * inv(1 - d * x1 * x2 * y1 * y2)
    return [x3 % q, y3 % q]


def add_elements(pt1, pt2): # extended->extended
    # add-2008-hwcd-3 . Slightly slower than add-2008-hwcd-4, but -3 is
    # unified, so it's safe for general-purpose addition
    (X1, Y1, Z1, T1) = pt1
    (X2, Y2, Z2, T2) = pt2
    A = ((Y1-X1)*(Y2-X2)) % q  # 255 bits
    B = ((Y1+X1)*(Y2+X2)) % q  # 255 bits
    C = T1*(2*d)*T2 % q  # 255 bits
    D = Z1*2*Z2 % q  # 255 bits
    E = (B-A) #% q
    F = (D-C) #% q
    G = (D+C) #% q
    H = (B+A) #% q
    X3 = (E*F) % q
    Y3 = (G*H) % q
    T3 = (E*H) % q
    Z3 = (F*G) % q

    # print pt1
    # print pt2
    print 'mult1', Y1 - X1
    print 'mult2', Y2 - X2
    print 'A', A
    print 'B', B
    print 'C', C
    print 'D', D
    print 'E', E
    print 'F', F
    print 'G', G
    print 'H', H

    return (X3, Y3, Z3, T3)

# x3, y3, z3, t3 = add_elements((3, 5, 7, 9), (4, 6, 8, 10))
# print 'x3', x3
# print 'y3', y3
# print 'z3', z3
# print 't3', t3

def xform_affine_to_extended(pt):
    (x, y) = pt
    return (x%q, y%q, 1, (x*y)%q) # (X,Y,Z,T)

# print xform_affine_to_extended(B)

def ed(n, pt):
    (X, Y, Z, T) = pt
    Q = (0, 1, 1, 0)
    for i in bin(n)[2:]:
        Q = add_elements(Q, Q)
        print 'DOUBLE', Q
        # print Q
        if i == '1':
            print 'Q', Q
            print 'pt', pt
            Q = add_elements(Q, pt)
            print 'ADD', Q
    return Q

# print ed(25, (0, 1, 1, 0))
print ed(25, xform_affine_to_extended(B))



def scalarmult(P, e):
    """ Q = eP """
    if e == 0:
        return [0, 1]
    Q = scalarmult(P, e / 2)
    Q = edwards(Q, Q)
    if e & 1:
        Q = edwards(Q, P)
    return Q

# print scalarmult(B, 3)