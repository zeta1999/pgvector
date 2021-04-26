EXTENSION = vector
DATA = vector--0.1.1.sql vector--0.1.0--0.1.1.sql
MODULE_big = vector
OBJS = src/ivfbuild.o src/ivfflat.o src/ivfinsert.o src/ivfkmeans.o src/ivfscan.o src/ivfutils.o src/ivfvacuum.o src/vector.o

TESTS = $(wildcard sql/*.sql)

REGRESS = btree cast copy functions ivfflat_cosine ivfflat_ip ivfflat_l2 ivfflat_unlogged vector

# For auto-vectorization:
# - GCC needs (-ffast-math OR -fassociative-math/-fno-signed-zeros/-fno-trapping-math) AND (-O3 OR -ftree-vectorize) - https://gcc.gnu.org/projects/tree-ssa/vectorization.html
# - Clang needs -ffast-math OR pragma - https://llvm.org/docs/Vectorizers.html
PG_CFLAGS = -O3 -march=native -fassociative-math -fno-signed-zeros -fno-trapping-math

# Debug GCC auto-vectorization
# PG_CFLAGS += -fopt-info-vec

# Debug Clang auto-vectorization
# PG_CFLAGS += -Rpass=loop-vectorize -Rpass-missed=loop-vectorize

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

prove_installcheck:
	rm -rf $(CURDIR)/tmp_check
	cd $(srcdir) && TESTDIR='$(CURDIR)' PATH="$(bindir):$$PATH" PGPORT='6$(DEF_PGPORT)' PG_REGRESS='$(top_builddir)/src/test/regress/pg_regress' $(PROVE) $(PG_PROVE_FLAGS) $(PROVE_FLAGS) $(if $(PROVE_TESTS),$(PROVE_TESTS),t/*.pl)
