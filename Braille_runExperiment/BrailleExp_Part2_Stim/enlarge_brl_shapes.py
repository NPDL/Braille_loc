import matplotlib.pyplot as plt
from scipy import misc

# shapes
# for group in [1,2]:
	# for stimset in range(1,21):
		# fig, axs = plt.subplots(6, figsize=(6,8))
		# for stim in range(1,7):
			# img_file = "Group%(group)d\BrailleExp_Part2_Stim_Braille_SS\ss_%(stimset)d\ss_%(stimset)d_%(stim)d.bmp"%{"group":group, "stimset":stimset, "stim":stim}
			# name = "Set%.2d\nShape%d"%(stimset,stim)
			# if stim == 7:
				# img_file = "Group%(group)d\BrailleExp_Part2_Stim_Braille_SS_YP\ssyp_%(stimset)d.bmp"%{"group":group, "stimset":stimset}
				# name = "Set%.2d\nYES"%stimset
			# if stim == 8:
				# img_file = "Group%(group)d\BrailleExp_Part2_Stim_Braille_SS_NP\ssnp_%(stimset)d.bmp"%{"group":group, "stimset":stimset}
				# name = "Set%.2d\nNO"%stimset
			
			# img = misc.imread(img_file, flatten=0)

			# axs[stim-1].matshow(255-img[:8,10:], cmap = "binary")
			# axs[stim-1].set_xticks([])
			# axs[stim-1].set_yticks([])
			
			# axs[stim-1].set_ylabel(name, rotation="horizontal", va="center", ha="right")
		# plt.savefig("stim_compile_enlarge/Group%d_set%d.png"%(group,stimset))
		# # plt.show()
		
# word list
def plot_word