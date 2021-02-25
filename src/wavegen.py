data_size = 100
noise = 1 # the higher the noisier

# we now open the file input_vectors.txt so that the vhd code can process it
f = open("input.txt", "w")

for i in range(data_size):
    sig = 60*(np.sin(i/10)+ noise)
    noise = -noise
    f.write('%d\n' % sig.astype(int)) # we write it as an int
