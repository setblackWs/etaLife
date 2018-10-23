package pl.setblack.etalife;
import javafx.application.Application;
import pl.setblack.life.LifeJ;
import javafx.concurrent.ScheduledService;
import javafx.concurrent.Task;
import javafx.embed.swing.SwingFXUtils;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import javafx.util.Duration;

import java.awt.*;
import java.awt.image.BufferedImage;

public class LifeWindow extends  Application{
    int statePointer = 0;
    @Override
    public void start(Stage primaryStage) throws Exception {


        int logicalWidth = 160;
        int logicalHeight = 160;
        int cwi= logicalWidth*8;
        int chi= logicalHeight*8;
        BufferedImage image = new BufferedImage(logicalWidth, logicalHeight, BufferedImage.TYPE_3BYTE_BGR);

        statePointer = initPlane(logicalWidth, logicalHeight, image);

        BorderPane border = new BorderPane();

        Image fxImage = SwingFXUtils.toFXImage(image, null);

        Canvas canvas = new Canvas(cwi, chi);
        GraphicsContext gc = canvas.getGraphicsContext2D();
        gc.drawImage(fxImage,0,0, cwi, chi);

        canvas.widthProperty().bind(border.widthProperty().subtract(10));
        canvas.heightProperty().bind(border.heightProperty().subtract(30));

        Button button = new Button("next>>");

        Runnable makeStep = () -> {
            GraphicsContext gc1 = canvas.getGraphicsContext2D();
            int prevState = statePointer;
            statePointer = LifeJ.newState(statePointer);
            //Life.freeState(prevState);
            System.out.println("new state:"+ statePointer);
            LifeJ.fillImage(statePointer, image);
            Image fxImage1 = SwingFXUtils.toFXImage(image, null);
            System.out.println("canvas dim:" + canvas.getWidth());
            //gc1.drawImage(fxImage1,0,0, cwi, chi);
            gc1.drawImage(fxImage1,0,0, canvas.getWidth(), canvas.getHeight());
        };

        button.setOnAction( e -> {
            makeStep.run();
        });

        border.setCenter(canvas);
        Button autobutton = new Button("auto");
        autobutton.setOnAction( e -> {
            ScheduledService<Void> svc = new ScheduledService<Void>() {
                protected Task<Void> createTask() {
                    return new Task<Void>() {
                        protected Void call() {

                            makeStep.run();
                            return null;
                        }
                    };
                }
            };
            svc.setPeriod(Duration.millis(20));
            svc.start();

        });
        HBox hbox = new HBox(8);
        hbox.getChildren().addAll(button, autobutton);
        border.setBottom(hbox);
        primaryStage.setScene(new Scene(border));
          primaryStage.show();
    }

    private int initPlane(int logicalWidth, int logicalHeight, BufferedImage image) {

        int state = LifeJ.initEmpty(logicalWidth-1, logicalHeight-1);


        for (int i=0 ; i < logicalWidth/2; i++) {
            state = LifeJ.setCell(state, i+logicalWidth/4, logicalHeight/2, Color.WHITE);
        }


        LifeJ.fillImage(state, image);
        return state;
    }
}
