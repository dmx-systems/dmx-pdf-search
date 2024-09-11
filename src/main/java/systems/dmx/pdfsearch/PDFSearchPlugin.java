package systems.dmx.pdfsearch;

import systems.dmx.core.ChildTopics;
import systems.dmx.core.Topic;
import systems.dmx.core.osgi.PluginActivator;
import systems.dmx.core.service.Inject;
import systems.dmx.core.service.event.PostCreateTopic;
import static systems.dmx.files.Constants.*;
import systems.dmx.files.FilesService;
import systems.dmx.tesseract.TesseractService;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.File;
import java.util.Arrays;
import java.util.logging.Logger;



public class PDFSearchPlugin extends PluginActivator implements PostCreateTopic {

    // ------------------------------------------------------------------------------------------------------- Constants

    // ---------------------------------------------------------------------------------------------- Instance Variables

    @Inject private FilesService files;
    @Inject private TesseractService tesseract;

    private Logger logger = Logger.getLogger(getClass().getName());

    // -------------------------------------------------------------------------------------------------- Public Methods

    // *** Listeners ***

    @Override
    public void postCreateTopic(Topic topic) {
        if (topic.getTypeUri().equals(FILE)) {
            ChildTopics ct = topic.getChildTopics();
            String path = ct.getTopic(PATH).getSimpleValue().toString();
            Topic mediaType = ct.getTopicOrNull(MEDIA_TYPE);
            if (mediaType == null) {
                logger.warning("No media type set for File topic " + topic.getId() + ", path=\"" + path + "\"");
                return;
            }
            if (mediaType.getSimpleValue().toString().equals("application/pdf")) {
                logger.info("### Indexing PDF file \"" + path + "\"");
                indexPDF(path, topic.getId());
            }
        }
    }

    // ------------------------------------------------------------------------------------------------- Private Methods

    private void indexPDF(String path, long topicId) {
        try {
            File file = files.getFile(path);
            // 1) Text extraction
            PDDocument pdfDocument = Loader.loadPDF(file);
            String text = new PDFTextStripper().getText(pdfDocument);
            logger.fine("\"" + text + "\"");
            logger.info(text.length() + " characters extracted" + (text.length() < 100 ? "\n" +
                Arrays.toString(text.getBytes()) : ""));
            if (isTextAvailable(text)) {
                dmx.indexTopicFulltext(topicId, text, FILE);
                return;
            }
            // 2) OCR
            text = tesseract.doOCR(path);
            dmx.indexTopicFulltext(topicId, text, FILE);
        } catch (Exception e) {
            throw new RuntimeException("Indexing PDF failed, path=\"" + path + "\", File topicId=" + topicId, e);
        }
    }

    private boolean isTextAvailable(String text) {
        return text.chars().anyMatch(c -> c != 10);    // LF
    }
}
