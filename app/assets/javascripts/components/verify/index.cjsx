# @cjsx React.DOM
React              = require 'react'
{Navigation}       = require 'react-router'
SubjectViewer      = require '../subject-viewer'
ZoomPanListenerMethods  = require 'lib/zoom-pan-listener-methods'
ZoomToolbar             = require '../zoom-toolbar'
JSONAPIClient      = require 'json-api-client' # use to manage data?
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'
ForumSubjectWidget = require '../forum-subject-widget'

BaseWorkflowMethods     = require 'lib/workflow-methods-mixin'

DraggableModal          = require 'components/draggable-modal'
GenericButton           = require 'components/buttons/generic-button'
Tutorial                = require 'components/tutorial'
HelpModal               = require 'components/help-modal'
LoadingIndicator        = require('components/loading-indicator')

# Hash of core tools:
coreTools          = require 'components/core-tools'

# Hash of transcribe tools:
verifyTools   = require './tools'

API                = require '../../lib/api'

module.exports = React.createClass # rename to Classifier
  displayName: 'Verify'
  mixins: [FetchSubjectsMixin, BaseWorkflowMethods, Navigation, ZoomPanListenerMethods] # load subjects and set state variables: subjects,  classification

  getDefaultProps: ->
    workflowName: 'verify'

  getInitialState: ->
    taskKey:                      null
    classifications:              []
    classificationIndex:          0
    subject_index:                0
    showingTutorial:              false
    helping:                      false
    toolbar_expanded:             false

  componentWillMount: ->
    @beginClassification()

  fetchSubjectsCallback: ->
    @setState taskKey: @getCurrentSubject().type if @getCurrentSubject()?

  toggleTutorial: ->
    @setState showingTutorial: not @state.showingTutorial

  hideTutorial: ->
    @setState showingTutorial: false

  toggleHelp: ->
    @setState helping: not @state.helping

  onToolbarExpand: ->
    @setState toolbar_expanded: true

  onToolbarHide: ->
    @setState toolbar_expanded: false

  render: ->
    currentAnnotation = @getCurrentClassification().annotation

    onFirstAnnotation = currentAnnotation?.task is @getActiveWorkflow().first_task

    <div className="classifier">
      <div className="subject-area">
        { if @state.noMoreSubjects
            <DraggableModal
              header          = { if @state.userClassifiedAll then "You verified them all!" else "Nothing to verify" }
              buttons         = {<GenericButton label='Continue' href='/#' />}
            >
              Currently, there are no {@props.project.term('subject')}s for you to {@props.workflowName}. Try <a href="/#/mark">marking</a> or <a href="/#/transcribe">transcribing</a> instead!
            </DraggableModal>

          else if ! @state.subjects?
            <LoadingIndicator />

          else if @getCurrentSubject()?
            <div key="#{@getCurrentSubject().id}" className={"subject-set-viewer" + if @state.toolbar_expanded then ' expand' else ''}>
              <ZoomToolbar
                subject={@getCurrentSubject()}
                onZoomChange={@handleZoomPanViewBoxChange}
                onExpand={@onToolbarExpand}
                onHide={@onToolbarHide}
                viewBox={@state.zoomPanViewBox}
              />
              <SubjectViewer 
                onLoad={@handleViewerLoad} 
                subject={@getCurrentSubject()} 
                active=true 
                workflow={@getActiveWorkflow()}
                viewBox={@state.zoomPanViewBox} 
                classification={@props.classification} 
                annotation={currentAnnotation}>
                
                { if ( VerifyComponent = @getCurrentTool() )?
                  <VerifyComponent
                    viewerSize={@state.viewerSize}
                    task={@getCurrentTask()}
                    annotation={@getCurrentClassification().annotation}
                    onShowHelp={@toggleHelp if @getCurrentTask().help?}
                    badSubject={@state.badSubject}
                    onBadSubject={@toggleBadSubject}
                    subject={@getCurrentSubject()}
                    onChange={@handleTaskComponentChange}
                    clearAnnotation={@clearCurrentAnnotation}
                    onComplete={@handleTaskComplete}
                    workflow={@getActiveWorkflow()}
                    project={@props.project}
                  />
                }
              </SubjectViewer>
            </div>
        }
      </div>

      { if @getCurrentSubject()?
          <div className="right-column">
            <div className="task-area verify">

              <div className="task-secondary-area">

                {
                  if @getCurrentTask()?
                    <p>
                      <a className="tutorial-link" onClick={@toggleTutorial}>View A Tutorial</a>
                    </p>
                }

                {
                  if @getCurrentSubject()?.meta_data?.subject_url?
                    <p>
                      <a className="view-original-link" href="#{@getCurrentSubject().meta_data.subject_url}" target="_blank">
                        View the original {@props.project.term('subject')}
                      </a>
                    </p>
                }

                <div className="forum-holder">
                  <ForumSubjectWidget subject=@getCurrentSubject() project={@props.project} />
                </div>

              </div>

            </div>
          </div>
      }

      { if @props.project.tutorial? && @state.showingTutorial
          # Check for workflow-specific tutorial
          if @props.project.tutorial.workflows? && @props.project.tutorial.workflows[@getActiveWorkflow()?.name]
            <Tutorial tutorial={@props.project.tutorial.workflows[@getActiveWorkflow().name]} onCloseTutorial={@hideTutorial} />
          # Otherwise just show general tutorial
          else
            <Tutorial tutorial={@props.project.tutorial} onCloseTutorial={@hideTutorial} />
      }

      { if @state.helping
        <HelpModal help={@getCurrentTask().help} onDone={=> @setState helping: false } />
      }
    </div>

window.React = React
