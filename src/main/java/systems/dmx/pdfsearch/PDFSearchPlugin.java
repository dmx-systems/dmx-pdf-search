package systems.dmx.pdfsearch;

import systems.dmx.core.ChildTopics;
import systems.dmx.core.Topic;
import systems.dmx.core.osgi.PluginActivator;
import systems.dmx.core.service.Inject;
import systems.dmx.core.service.event.PostCreateTopic;
import static systems.dmx.files.Constants.*;
import systems.dmx.files.FilesService;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.File;
import java.util.logging.Logger;



public class PDFSearchPlugin extends PluginActivator implements PostCreateTopic {

    // ------------------------------------------------------------------------------------------------------- Constants

    // ---------------------------------------------------------------------------------------------- Instance Variables

    @Inject
    private FilesService files;

    private Logger logger = Logger.getLogger(getClass().getName());

    // -------------------------------------------------------------------------------------------------- Public Methods

    // *** Listeners ***

    @Override
    public void postCreateTopic(Topic topic) {
        if (topic.getTypeUri().equals(FILE)) {
            ChildTopics ct = topic.getChildTopics();
            String mediaType = ct.getTopic(MEDIA_TYPE).getSimpleValue().toString();
            if (mediaType.equals("application/pdf")) {
                String path = ct.getTopic(PATH).getSimpleValue().toString();
                logger.info("### Indexing PDF file \"" + path + "\"");
                File file = files.getFile(path);
                indexPDF(file);
            }
        }
    }

    // ------------------------------------------------------------------------------------------------- Private Methods

    private void indexPDF(File file) {
        try {
            PDDocument pdfDocument = Loader.loadPDF(file);
            String text = new PDFTextStripper().getText(pdfDocument);
            logger.info(text);
            // TODO
        } catch (Exception e) {
            throw new RuntimeException("Indexing PDF failed, file=\"" + file + "\"");
        }
    }
}
