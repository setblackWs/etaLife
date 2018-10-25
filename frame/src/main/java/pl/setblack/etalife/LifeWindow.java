package pl.setblack.etalife;

import javafx.application.Application;
import javafx.concurrent.ScheduledService;
import javafx.concurrent.Task;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.WritableImage;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import javafx.util.Duration;
import pl.setblack.life.LifeJ;
import javafx.beans.value.ChangeListener;
import java.awt.Color;

/**
 * Simple JavaFX application that displays game of life generations
 */
public class LifeWindow extends  Application{

    int statePointer = 0;

    @Override
    public void start(Stage primaryStage) throws Exception {
        int logicalWidth = 160;
        int logicalHeight = 160;


        WritableImage image = new WritableImage(logicalWidth,logicalHeight);
        statePointer = initPlane(logicalWidth, logicalHeight, image);

        BorderPane mainComponent = new BorderPane();
        Canvas canvas = createCanvas(logicalWidth, logicalHeight, mainComponent, image);

        Runnable makeStep = makeStep(image, canvas);
        HBox buttons = makeButtons(makeStep, mainComponent, canvas);
        mainComponent.setBottom(buttons);

        Scene scene = new Scene(mainComponent);
        primaryStage.setScene(scene);
        scene.getStylesheets().add(getClass().getResource("/style.css").toExternalForm());

        handleResize(primaryStage, image, canvas);

        primaryStage.show();
    }

    private void handleResize(Stage primaryStage, WritableImage image, Canvas canvas) {
        ChangeListener<Number> stageSizeListener = (observable, oldValue, newValue) ->
                redrawImage(image, canvas);

        primaryStage.widthProperty().addListener(stageSizeListener);
        primaryStage.heightProperty().addListener(stageSizeListener);
    }

    private HBox makeButtons(Runnable makeStep, BorderPane border, Canvas canvas) {
        Button button = new Button("next>>");
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
        hbox.setPrefHeight(200);
        hbox.getChildren().addAll(button, autobutton);
        return hbox;
    }

    private Canvas createCanvas(int cwi, int chi, BorderPane border, Image fxImage) {
        Canvas canvas = new Canvas(cwi, chi);
        GraphicsContext gc = canvas.getGraphicsContext2D();
        gc.drawImage(fxImage,0,0, cwi, chi);

        canvas.widthProperty().bind(border.widthProperty().subtract(10));
        canvas.heightProperty().bind(border.heightProperty().subtract(40));

        canvas.setOnMouseClicked( ev -> {
            System.out.println(ev);

        });

        return canvas;
    }

    private void redrawImage( WritableImage image, Canvas canvas) {
        GraphicsContext gc1 = canvas.getGraphicsContext2D();
        gc1.drawImage(image,0,0, canvas.getWidth(), canvas.getHeight());
    }
    private Runnable makeStep(WritableImage image, Canvas canvas) {
        return () -> {

                int prevState = statePointer;
                statePointer = LifeJ.newState(statePointer);
                LifeJ.freeState(prevState);
                System.out.println("new state:"+ statePointer);
                LifeJ.fillImage(statePointer, image.getPixelWriter());
                redrawImage(image, canvas);

            };
    }

    private int initPlane(int logicalWidth, int logicalHeight, WritableImage image) {
        int state = LifeJ.initEmpty(logicalWidth-1, logicalHeight-1);
        for (int i=0 ; i < logicalWidth/2; i++) {
            state = LifeJ.setCell(state, i+logicalWidth/4, logicalHeight/2, Color.WHITE);
        }
        LifeJ.fillImage(state, image.getPixelWriter());
        return state;
    }
}
