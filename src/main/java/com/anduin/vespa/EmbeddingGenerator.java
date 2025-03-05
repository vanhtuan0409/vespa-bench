// Copyright Vespa.ai. All rights reserved.
package com.anduin.vespa;

import com.yahoo.docproc.DocumentProcessor;
import com.yahoo.docproc.Processing;
import com.yahoo.document.DocumentOperation;
import com.yahoo.document.DocumentPut;
import com.yahoo.document.datatypes.TensorFieldValue;
import com.yahoo.tensor.*;

import java.util.Random;

public class EmbeddingGenerator extends DocumentProcessor {

	// Must match the type of 'embedding' field in test.sd
	private static int tensorSize = 256;
	private static String tensorField = "embedding";
	private static TensorType tensorType = TensorType.fromSpec(String.format("tensor<bfloat16>(x[%d])", tensorSize));

	private ThreadLocal<Random> localRandom = ThreadLocal.withInitial(() -> new Random());

	private float[] createRandomVector(int dimension) {
		var rnd = localRandom.get();
		var res = new float[dimension];
		for (int i = 0; i < dimension; ++i) {
			res[i] = (float) (rnd.nextInt() % 100000) / 100000.0f;
		}
		return res;
	}

	private TensorFieldValue createEmbedding(int dimension) {
		var tensor = IndexedTensor.Builder.of(tensorType, createRandomVector(dimension)).build();
		return new TensorFieldValue(tensor);
	}

	@Override
	public Progress process(Processing proc) {
		for (DocumentOperation op : proc.getDocumentOperations()) {
			if (op instanceof DocumentPut) {
				var doc = ((DocumentPut) op).getDocument();
				doc.setFieldValue(tensorField, createEmbedding(tensorSize));
			}
		}
		return Progress.DONE;
	}
}
